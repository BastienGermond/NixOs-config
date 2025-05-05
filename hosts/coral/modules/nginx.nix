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

      importHost = host: overrides: let
        f = import host;
      in
        f ((builtins.intersectAttrs (builtins.functionArgs f) (pkgs // {inherit config anemone coral withDefaultConfiguration;})) // overrides);
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

      "alert.germond.org" = importHost ./nginx/alert.germond.org.nix {};
      "cache.germond.org" = importHost ./nginx/cache.germond.org.nix {};
      "cloud.germond.org" = importHost ./nginx/cloud.germond.org.nix {};
      "docs.germond.org" = importHost ./nginx/docs.germond.org.nix {};
      "germond.org" = importHost ./nginx/germond.org.nix {};
      "git.germond.org" = importHost ./nginx/git.germond.org.nix {};
      "grafana.germond.org" = importHost ./nginx/grafana.germond.org.nix {};
      "hackmd.germond.org" = importHost ./nginx/hackmd.germond.org.nix {};
      "home.germond.org" = importHost ./nginx/home.germond.org.nix {};
      "immich.germond.org" = importHost ./nginx/immich.germond.org.nix {};
      "komga.germond.org" = importHost ./nginx/komga.germond.org.nix {};
      "minio.germond.org" = importHost ./nginx/minio.germond.org.nix {};
      "newsso.germond.org" = importHost ./nginx/newsso.germond.org.nix {};
      "paperless.germond.org" = importHost ./nginx/paperless.germond.org.nix {};
      "prometheus.germond.org" = importHost ./nginx/prometheus.germond.org.nix {};
      "s3-garage.germond.org" = importHost ./nginx/s3.garage.germond.org.nix {};
      "s3.germond.org" = importHost ./nginx/s3.germond.org.nix {};
      "scrutiny.germond.org" = importHost ./nginx/scrutiny.germond.org.nix {};
      "status.germond.org" = importHost ./nginx/status.germond.org.nix {};
      "t.germond.org" = importHost ./nginx/t.germond.org.nix {};
      "videos.germond.org" = importHost ./nginx/videos.germond.org.nix {};
      "vouch.germond.org" = importHost ./nginx/vouch.germond.org.nix {};
      "web-garage.germond.org" = importHost ./nginx/web.garage.germond.org.nix {};
      "komf.germond.org" = importHost ./nginx/komf.germond.org.nix {};
      "suwayomi.germond.org" = importHost ./nginx/suwayomi.germond.org.nix {};
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
