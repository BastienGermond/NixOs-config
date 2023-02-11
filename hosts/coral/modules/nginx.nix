{ config, lib, pkgs, infra, ... }:

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

    virtualHosts =
      let
        withDefaultConfiguration = name: conf: lib.mkMerge [
          {
            forceSSL = true;

            extraConfig = ''
              access_log /var/log/nginx/access-${name}.log;
            '';
          }

          (if (builtins.match ".*germond\.org" name) != null then {
            useACMEHost = "germond.org";
            acmeRoot = null;
          } else { })

          conf
        ];
      in
      {
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

        "sso.germond.org" = withDefaultConfiguration "sso.germond.org" {
          locations."/" = {
            proxyPass = "http://${infra.hosts.anemone.ips.vpn.A}:9000/";
            proxyWebsockets = true;
          };
        };

        "cloud.germond.org" = withDefaultConfiguration "cloud.germond.org" {
          locations."/" = {
            proxyPass = "http://${infra.hosts.anemone.ips.vpn.A}/";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 10G;
            '';
          };
        };

        "grafana.germond.org" = withDefaultConfiguration "grafana.germond.org" {
          root = config.services.grafana.settings.server.static_root_path;

          locations."/".tryFiles = "$uri @grafana";

          locations."@grafana" = {
            proxyPass = "http://grafana";
            proxyWebsockets = true;
          };
        };

        "status.germond.org" = withDefaultConfiguration "status.germond.org" {
          locations."/" = {
            proxyPass = "http://${gatusWebCfg.address}:${builtins.toString gatusWebCfg.port}";
            proxyWebsockets = true;
          };
        };

        "minio.germond.org" = withDefaultConfiguration "minio.germond.org" {
          locations."/" = {
            proxyPass = "http://${infra.hosts.anemone.ips.vpn.A}:9031";
            proxyWebsockets = true;
          };
        };

        "s3.germond.org" = withDefaultConfiguration "s3.germond.org" {
          locations."/" = {
            proxyPass = "http://${infra.hosts.anemone.ips.vpn.A}:9030";
          };
        };

        "t.germond.org" = withDefaultConfiguration "t.germond.org" {
          locations."/" = {
            proxyPass = "http://${config.services.transfer_sh.config.listener}";
            extraConfig = ''
              client_max_body_size 2G;
            '';
          };
        };

        "paperless.germond.org" = withDefaultConfiguration "paperless.germond.org" {
          extraConfig = ''
            proxy_buffers 8 16k;
            proxy_buffer_size 32k;
          '';

          locations."/" = {
            priority = 50;
            proxyWebsockets = true;
            extraConfig = ''
              proxy_pass http://${infra.hosts.anemone.ips.vpn.A}:28981;

              proxy_redirect off;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $server_name;

              ##############################
              # authentik-specific config
              ##############################
              auth_request     /outpost.goauthentik.io/auth/nginx;
              error_page       401 = @goauthentik_proxy_signin;
              auth_request_set $auth_cookie $upstream_http_set_cookie;
              add_header       Set-Cookie $auth_cookie;

              # translate headers from the outposts back to the actual upstream
              auth_request_set $authentik_username $upstream_http_x_authentik_username;
              auth_request_set $authentik_groups $upstream_http_x_authentik_groups;
              auth_request_set $authentik_email $upstream_http_x_authentik_email;
              auth_request_set $authentik_name $upstream_http_x_authentik_name;
              auth_request_set $authentik_uid $upstream_http_x_authentik_uid;

              proxy_set_header X-authentik-username $authentik_username;
              proxy_set_header X-authentik-groups $authentik_groups;
              proxy_set_header X-authentik-email $authentik_email;
              proxy_set_header X-authentik-name $authentik_name;
              proxy_set_header X-authentik-uid $authentik_uid;
            '';
          };

          locations."/outpost.goauthentik.io" = {
            proxyWebsockets = true;
            extraConfig = ''
              proxy_pass              http://${infra.hosts.anemone.ips.vpn.A}:9000/outpost.goauthentik.io;
              # ensure the host of this vserver matches your external URL you've configured
              # in authentik
              proxy_set_header        Host $host;
              proxy_set_header        X-Original-URL $scheme://$http_host$request_uri;
              add_header              Set-Cookie $auth_cookie;
              auth_request_set        $auth_cookie $upstream_http_set_cookie;
              proxy_pass_request_body off;
              proxy_set_header        Content-Length "";
            '';
          };

          locations."@goauthentik_proxy_signin" = {
            proxyWebsockets = true;
            extraConfig = ''
              internal;
              add_header Set-Cookie $auth_cookie;
              return 302 /outpost.goauthentik.io/start?rd=$request_uri;
            '';
          };
        };

        "hackmd.germond.org" = withDefaultConfiguration "hackmd.germond.org" {
          locations."/" =
            let
              hedgedocHost = config.services.hedgedoc.settings.host;
              hedgedocPort = config.services.hedgedoc.settings.port;
            in
            {
              proxyPass = "http://${hedgedocHost}:${builtins.toString hedgedocPort}";
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
