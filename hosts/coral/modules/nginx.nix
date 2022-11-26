{ config, lib, pkgs, ... }:

let
  certs_mail_addr = "bastien.germond+certs@epita.fr";

  gistre_fr_site = pkgs.stdenv.mkDerivation {
    name = "gistre-fr-site";

    src = pkgs.fetchFromGitHub {
      owner = "BastienGermond";
      repo = "gistre.fr";
      rev = "efa716c7ff48c8d52cd19f9b55aa2fa92994b3bd";
      sha256 = "sha256-2WaFELIF7gXrelhPbhCnZ4ubO4E7KB7/HAy1piIKULY=";
    };

    installPhase = ''
      mkdir $out
      cp -r site/* $out
    '';
  };

  gatusWebCfg = config.services.gatus.config.web;
in
{
  users.users.nginx.extraGroups = [ "grafana" "acme" ];

  services.nginx = {
    enable = true;
    package = pkgs.nginxStable;
    recommendedProxySettings = true;

    upstreams = {
      grafana.servers = {
        "unix:/${config.services.grafana.settings.server.socket}" = { };
      };
    };

    virtualHosts = {
      # be the default to trap all the direct ip access.
      # TODO: fail2ban almost instantly those ips
      "trap" = {
        default = true;
        addSSL = true;
        sslCertificate = ../data/nginx/trap/certificate.pem;
        sslCertificateKey = config.sops.secrets.nginxTrapCertKey.path;

        locations."/".return = "444"; # 444 with nginx close connection without response.
      };

      "gistre.fr" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          access_log /var/log/nginx/access-gistre.fr.log;
        '';
        locations."/" = {
          root = "${gistre_fr_site}";
        };
      };

      "sso.germond.org" = {
        forceSSL = true;

        useACMEHost = "germond.org";
        acmeRoot = null;

        extraConfig = ''
          access_log /var/log/nginx/access-sso.germond.org.log;
        '';

        locations."/" = {
          proxyPass = "http://10.100.10.2:9000/";
          proxyWebsockets = true;
        };
      };

      "cloud.germond.org" = {
        forceSSL = true;

        useACMEHost = "germond.org";
        acmeRoot = null;

        extraConfig = ''
          access_log /var/log/nginx/access-cloud.germond.org.log;
        '';

        locations."/" = {
          proxyPass = "http://10.100.10.2/";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 10G;
          '';
        };
      };

      "grafana.germond.org" = {
        forceSSL = true;

        useACMEHost = "germond.org";
        acmeRoot = null;

        root = config.services.grafana.settings.server.static_root_path;

        extraConfig = ''
          access_log /var/log/nginx/access-grafana.germond.org.log;
        '';

        locations."/".tryFiles = "$uri @grafana";

        locations."@grafana" = {
          proxyPass = "http://grafana";
          proxyWebsockets = true;
        };
      };

      "status.germond.org" = {
        forceSSL = true;

        useACMEHost = "germond.org";
        acmeRoot = null;

        extraConfig = ''
          access_log /var/log/nginx/access-status.germond.org.log;
        '';

        locations."/" = {
          proxyPass = "http://${gatusWebCfg.address}:${builtins.toString gatusWebCfg.port}";
          proxyWebsockets = true;
        };
      };

      "minio.germond.org" = {
        forceSSL = true;

        useACMEHost = "germond.org";
        acmeRoot = null;

        extraConfig = ''
          access_log /var/log/nginx/access-minio.germond.org.log;
        '';

        locations."/" = {
          proxyPass = "http://10.100.10.2:9031";
        };
      };

      "s3.germond.org" = {
        forceSSL = true;

        useACMEHost = "germond.org";
        acmeRoot = null;

        extraConfig = ''
          access_log /var/log/nginx/access-s3.germond.org.log;
        '';

        locations."/" = {
          proxyPass = "http://10.100.10.2:9030";
        };
      };
    };
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = certs_mail_addr;
  security.acme.certs = {
    "gistre.fr" = { };
    "germond.org" = {
      dnsProvider = "rfc2136";
      credentialsFile = config.sops.secrets.acmeGermondOrgCredsEnv.path;
      extraDomainNames = [ "*.germond.org" ];
      dnsPropagationCheck = false;
    };
  };
}
