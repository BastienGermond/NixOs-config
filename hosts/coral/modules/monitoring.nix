{ config, pkgs, lib, ... }:

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

        alertmanager = {
          enable = true;
          environmentFile = config.sops.secrets.alertmanagerEnv.path;
          configuration = {
            route = {
              receiver = "telegram";
            };
            receivers = [
              {
                name = "telegram";
                telegram_configs = [
                  {
                    api_url = "https://api.telegram.org";
                    send_resolved = true;
                    bot_token = "\${AM_BOT_TOKEN}";
                    chat_id = -710661185;
                    parse_mode = "HTML";
                  }
                ];
              }
            ];
          };
        };

        alertmanagers = [{
          static_configs = [{
            targets = [ "10.100.10.1:9093" ];
          }];
        }];

        ruleFiles = [
          ../data/prometheus/host-alerts.yml
          ../data/prometheus/gatus.yml
        ];

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
          {
            job_name = "gatus";
            scheme = "https";
            static_configs = [{
              targets = [ "status.germond.org" ];
            }];
          }
        ];
      };

      systemd.services.grafana.serviceConfig = {
        # FIXME: Remove or keep ?
        # Without this grafana try to call sys_fchownat which is blocked without @chown;
        SystemCallFilter = [ "@chown" ];
      };

      services.grafana =
        let
          readFromFile = path: "$__file{${path}}";
          provisionConfDir = pkgs.runCommand "grafana-provisioning" { nativeBuildInputs = [ pkgs.xorg.lndir ]; } ''
            mkdir -p $out/{datasources,dashboards,notifiers,alerting,plugins}
          '';
        in
        {
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
            };

            "auth.generic_oauth" = {
              enabled = true;
              allow_sign_up = true;
              name = "Germond SSO";
              client_id = readFromFile config.sops.secrets.grafanaOAuthClientID.path;
              client_secret = readFromFile config.sops.secrets.grafanaOAuthSecret.path;
              scopes = "email openid profile grafana";
              auth_url = "https://sso.germond.org/application/o/authorize/";
              token_url = "https://sso.germond.org/application/o/token/";
              api_url = "https://sso.germond.org/application/o/userinfo/";
              allowed_domains = "gmail.com";
              role_attribute_path = "grafanaRole";
              email_attribute_path = "email";
              groups_attribute_path = "groups";
              name_attribute_path = "name";
              login_attribute_path = "preferred_username";
            };

            security.secret_key = readFromFile config.sops.secrets.grafanaSecretKey.path;

            database = {
              user = grafanaDbUser;
              type = "postgres";
              name = grafanaDbName;
              host = "127.0.0.1:5432";
            };
          };

          declarativePlugins = with pkgs.grafanaPlugins; [ ];

          provision = {
            enable = true;

            datasources.settings = {
              apiVersion = 1;

              datasources = [
                {
                  name = "Loki";
                  url = "http://10.100.10.1:3100";
                  type = "loki";
                  access = "proxy";
                  jsonData = {
                    manageAlerts = false;
                  };
                }
                {
                  name = "Prometheus";
                  url = "http://10.100.10.1:9001";
                  type = "prometheus";
                  access = "proxy";
                }
              ];
            };
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
