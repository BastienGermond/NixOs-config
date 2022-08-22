{ config, pkgs, ... }:

{
  config =
    let
      lokiDataDir = config.services.loki.dataDir;
      grafanaDbName = "grafana";
      grafanaDbUser = "grafana";
    in
    {
      services.postgresql = {
        enable = true;
        ensureUsers = [
          {
            name = grafanaDbUser;
            ensurePermissions = {
              "DATABASE \"${grafanaDbName}\"" = "ALL PRIVILEGES";
            };
          }
        ];
        ensureDatabases = [ grafanaDbName ];
      };

      services.prometheus = {
        enable = true;
        port = 9001;
        retentionTime = "15d";

        exporters = {
          node = {
            enable = true;
            enabledCollectors = [ "systemd" "processes" "cpu" ];
            port = 9002;
          };
        };

        scrapeConfigs = [
          {
            job_name = "anemone";
            static_configs = [{
              targets = [ "10.100.10.2:9002" ];
            }];
          }
          {
            job_name = "coral";
            static_configs = [{
              targets = [ "127.0.0.1:9002" ];
            }];
          }
        ];
      };

      services.grafana =
        let
          readFromFile = path: "$__file{${path}}";
        in
        {
          enable = true;
          domain = "grafana.germond.org";
          rootUrl = "https://grafana.germond.org/";
          protocol = "socket";

          extraOptions = {
            USERS_AUTO_ASSIGN_ORG = "true";
            USERS_AUTO_ASSIGN_ORG_ID = "1";

            AUTH_GENERIC_OAUTH_ENABLED = "true";
            AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP = "true";
            AUTH_GENERIC_OAUTH_NAME = "Germond SSO";

            AUTH_GENERIC_OAUTH_CLIENT_ID = readFromFile config.sops.secrets.grafanaOAuthClientID.path;
            AUTH_GENERIC_OAUTH_CLIENT_SECRET = readFromFile config.sops.secrets.grafanaOAuthSecret.path;

            AUTH_GENERIC_OAUTH_SCOPES = "email openid profile grafana";

            AUTH_GENERIC_OAUTH_AUTH_URL = "https://sso.germond.org/application/o/authorize/";
            AUTH_GENERIC_OAUTH_TOKEN_URL = "https://sso.germond.org/application/o/token/";
            AUTH_GENERIC_OAUTH_API_URL = "https://sso.germond.org/application/o/userinfo/";
            AUTH_GENERIC_OAUTH_ALLOWED_DOMAINS = "gmail.com";
            AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH = "grafanaRole";
            AUTH_GENERIC_OAUTH_EMAIL_ATTRIBUTE_PATH = "email";
            AUTH_GENERIC_OAUTH_GROUPS_ATTRIBUTE_PATH = "groups";
            AUTH_GENERIC_OAUTH_NAME_ATTRIBUTE_PATH = "name";
            AUTH_GENERIC_OAUTH_LOGIN_ATTRIBUTE_PATH = "preferred_username";
          };

          database = {
            user = grafanaDbUser;
            type = "postgres";
            name = grafanaDbName;
            host = "127.0.0.1:5432";
          };

          security = {
            secretKeyFile = config.sops.secrets.grafanaSecretKey.path;
          };

          declarativePlugins = with pkgs.grafanaPlugins; [ ];

          provision = {
            enable = true;

            datasources = [
              {
                name = "Loki";
                url = "http://10.100.10.1:3100";
                type = "loki";
                access = "proxy";
              }
            ];
          };
        };

      users.users.promtail.extraGroups = [ "nginx" ];

      services.promtail = {
        enable = true;
        configuration = {
          server.http_listen_port = 3031;
          server.grpc_listen_port = 0;

          clients = [{
            url = "http://10.100.10.1:3100/loki/api/v1/push";
          }];

          scrape_configs = [
            {
              job_name = "journal";
              journal = {
                max_age = "12h";
                labels = {
                  job = "systemd-journal";
                  host = config.networking.hostName;
                };
              };
              relabel_configs = [{
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }];
            }
            {
              job_name = "nginx";
              static_configs = [
                {
                  targets = [
                    "localhost"
                  ];
                  labels = {
                    __path__ = "/var/log/nginx/*.log";
                    job = "nginx";
                    host = config.networking.hostName;
                  };
                }
              ];
            }
          ];
        };
      };

      services.loki = {
        enable = true;
        configuration = {
          auth_enabled = false;

          server.http_listen_port = 3100;
          server.http_listen_address = "10.100.10.1";

          ingester = {
            lifecycler = {
              address = "10.100.10.1";
              ring = {
                kvstore = {
                  store = "inmemory";
                };
                replication_factor = 1;
              };
              final_sleep = "0s";
            };
            chunk_idle_period = "5m"; # "1h";
            chunk_retain_period = "30s";
          };

          schema_config = {
            configs = [
              {
                from = "2022-01-01";
                store = "boltdb";
                object_store = "filesystem";
                schema = "v11";
                index = {
                  prefix = "index_";
                  period = "24h";
                };
              }
            ];
          };

          storage_config = {
            boltdb = {
              directory = "${lokiDataDir}/index";
            };
            filesystem = {
              directory = "${lokiDataDir}/chunks";
            };
          };

          limits_config = {
            enforce_metric_name = false;
            reject_old_samples = true;
            reject_old_samples_max_age = "168h";
          };
        };
      };
    };
}
