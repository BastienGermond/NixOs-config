{
  config,
  lib,
  pkgs,
  infra,
  ...
}: let
  certs_mail_addr = "bastien.germond+certs@epita.fr";

  anemone = infra.hosts.anemone;
  coral = infra.hosts.coral;
in {
  users.users.nginx.extraGroups = ["grafana" "acme"];

  networking.firewall.allowedTCPPorts = [80 443 8448];

  services.nginx = {
    enable = true;
    package = pkgs.nginxStable;
    recommendedProxySettings = true;

    upstreams = {
      grafana.servers = {
        "unix:/${config.services.grafana.settings.server.socket}" = {};
      };
    };

    streamConfig = ''
      server {
        listen 22;
        proxy_pass 10.100.10.2:2222;
        proxy_protocol on;
      }
    '';

    virtualHosts = let
      withDefaultConfiguration = name: conf:
        lib.mkMerge [
          {
            forceSSL = true;

            extraConfig = ''
              access_log /var/log/nginx/access-${name}.log;
            '';
          }

          (
            if (builtins.match ".*germond\.org" name) != null
            then {
              useACMEHost = "germond.org";
              acmeRoot = null;
            }
            else {}
          )

          conf
        ];
    in {
      # be the default to trap all the direct ip access.
      # TODO: fail2ban almost instantly those ips
      "trap" = {
        default = true;
        addSSL = true;
        sslCertificate = ../data/nginx/trap/certificate.pem;
        sslCertificateKey = config.sops.secrets.nginxTrapCertKey.path;

        locations."/".return = "444"; # 444 with nginx close connection without response.
      };

      # "gistre.fr" = import ./nginx/gistre.fr.nix {inherit pkgs;};
      "germond.org" = import ./nginx/germond.org.nix {inherit anemone withDefaultConfiguration;};
      "newsso.germond.org" = import ./nginx/newsso.germond.org.nix {inherit coral withDefaultConfiguration;};
      "cloud.germond.org" = import ./nginx/cloud.germond.org.nix {inherit anemone withDefaultConfiguration;};
      "grafana.germond.org" = import ./nginx/grafana.germond.org.nix {inherit config withDefaultConfiguration;};
      "status.germond.org" = import ./nginx/status.germond.org.nix {inherit config withDefaultConfiguration;};
      "minio.germond.org" = import ./nginx/minio.germond.org.nix {inherit anemone withDefaultConfiguration;};
      "s3.germond.org" = import ./nginx/s3.germond.org.nix {inherit anemone withDefaultConfiguration;};
      "t.germond.org" = import ./nginx/t.germond.org.nix {inherit config withDefaultConfiguration;};
      "paperless.germond.org" = import ./nginx/paperless.germond.org.nix {inherit anemone withDefaultConfiguration;};
      "hackmd.germond.org" = import ./nginx/hackmd.germond.org.nix {inherit config withDefaultConfiguration;};
      "git.germond.org" = import ./nginx/git.germond.org.nix {inherit anemone withDefaultConfiguration;};
      "docs.germond.org" = import ./nginx/docs.germond.org.nix {inherit anemone withDefaultConfiguration;};
      "videos.germond.org" = import ./nginx/videos.germond.org.nix {inherit anemone withDefaultConfiguration;};
      "vouch.germond.org" = import ./nginx/vouch.germond.org.nix {inherit withDefaultConfiguration;};
      "prometheus.germond.org" = import ./nginx/prometheus.germond.org.nix {inherit pkgs lib config withDefaultConfiguration;};
      "home.germond.org" = import ./nginx/home.germond.org.nix {inherit coral withDefaultConfiguration;};
      "alert.germond.org" = import ./nginx/alert.germond.org.nix {inherit coral withDefaultConfiguration;};
      "scrutiny.germond.org" = import ./nginx/scrutiny.germond.org.nix {inherit config withDefaultConfiguration;};
      "cache.germond.org" = import ./nginx/cache.germond.org.nix {inherit coral withDefaultConfiguration;};
      "immich.germond.org" = import ./nginx/immich.germond.org.nix {inherit anemone withDefaultConfiguration;};
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = certs_mail_addr;
  security.acme.certs = {
    # "gistre.fr" = {};
    "germond.org" = {
      dnsProvider = "rfc2136";
      credentialsFile = config.sops.secrets.acmeGermondOrgCredsEnv.path;
      extraDomainNames = ["*.germond.org"];
      dnsPropagationCheck = false;
    };
  };
}
