{
  config,
  pkgs,
  lib,
  infra,
  ...
}: let
  grafanaDbName = "grafana";
  grafanaDbUser = "grafana";

  coral = infra.hosts.coral;
in {
  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = grafanaDbUser;
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [grafanaDbName];
  };

  services.postgresqlCipheredBackup.databases = [grafanaDbName];

  services.grafana = let
    readFromFile = path: "$__file{${path}}";
    provisionConfDir = pkgs.runCommand "grafana-provisioning" {nativeBuildInputs = [pkgs.xorg.lndir];} ''
      mkdir -p $out/{datasources,dashboards,notifiers,alerting,plugins}
    '';
  in {
    enable = true;

    settings = {
      server = {
        protocol = "socket";
        domain = "grafana.germond.org";
        root_url = "https://grafana.germond.org/";
      };

      paths = {
        provisioning = provisionConfDir;
      };

      log = {
        level = "info";
      };

      users = {
        auto_assign_org = true;
        auto_assign_org_id = 1;
        auto_assign_org_role = "Viewer";
      };

      "auth.generic_oauth" = {
        enabled = true;
        allow_sign_up = true;
        name = "Germond SSO";
        client_id = readFromFile config.sops.secrets.grafanaOAuthClientID.path;
        client_secret = readFromFile config.sops.secrets.grafanaOAuthSecret.path;
        scopes = "email openid profile grafana";
        auth_url = "https://newsso.germond.org/realms/germond/protocol/openid-connect/auth";
        token_url = "https://newsso.germond.org/realms/germond/protocol/openid-connect/token";
        api_url = "https://newsso.germond.org/realms/germond/protocol/openid-connect/userinfo";
        allowed_domains = "gmail.com,germond.org";
        role_attribute_path = "grafanaRole";
        allow_assign_grafana_admin = true;
        email_attribute_path = "email";
        groups_attribute_path = "groups";
        name_attribute_path = "name";
        login_attribute_path = "preferred_username";
      };

      "auth.anonymous" = {
        enabled = false;
      };

      security.secret_key = readFromFile config.sops.secrets.grafanaSecretKey.path;

      database = {
        user = grafanaDbUser;
        type = "postgres";
        name = grafanaDbName;
        host = "127.0.0.1:${builtins.toString config.services.postgresql.port}";
      };
    };

    declarativePlugins = with pkgs.grafanaPlugins; [
      grafana-piechart-panel
    ];

    provision = {
      enable = true;

      datasources.settings = {
        apiVersion = 1;

        datasources = [
          {
            name = "Loki";
            url = "http://${coral.ips.vpn.A}:${builtins.toString coral.ports.loki}";
            type = "loki";
            access = "proxy";
            jsonData = {
              manageAlerts = false;
            };
          }
          {
            name = "Prometheus";
            url = "http://${coral.ips.vpn.A}:${builtins.toString coral.ports.prometheus}";
            type = "prometheus";
            access = "proxy";
          }
        ];
      };
    };
  };
}
