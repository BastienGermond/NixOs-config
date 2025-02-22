{
  config,
  pkgs,
  lib,
  infra,
  ...
}: let
  lokiDataDir = config.services.loki.dataDir;

  coral = infra.hosts.coral;
  anemone = infra.hosts.anemone;
in {
  services.prometheus = {
    port = coral.ports.prometheus;

    webExternalUrl = "https://prometheus.germond.org";

    retentionTime = "15d";

    checkConfig = "syntax-only";

    alertmanager = {
      port = coral.ports.alert-manager;
      webExternalUrl = "https://alert.germond.org";
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

    alertmanagers = [
      {
        static_configs = [
          {
            targets = ["${coral.ips.vpn.A}:${toString coral.ports.alert-manager}"];
          }
        ];
      }
    ];

    ruleFiles = [
      ../data/prometheus/host-alerts.yml
      ../data/prometheus/gatus.yml
      ../data/prometheus/synapse-v2.rules
      ../data/prometheus/dmarc-alerts.yml
    ];

    exporters = {
      node = {
        enabledCollectors = ["systemd" "processes" "cpu"];
        port = coral.ports.node-exporter;
      };
      dmarc = {
        imap = {
          host = "germond.org";
          username = "abuse@germond.org";
          passwordFile = config.sops.secrets.imapPassword.path;
        };
        pollIntervalSeconds = 3600;
      };
    };

    scrapeConfigs = [
      {
        job_name = "anemone";
        static_configs = [
          {
            targets = [
              "${anemone.ips.vpn.A}:${builtins.toString anemone.ports.node-exporter}"
              "${anemone.ips.vpn.A}:${builtins.toString anemone.ports.systemd-exporter}"
              "${anemone.ips.vpn.A}:${builtins.toString anemone.ports.cadvisor}"
            ];
          }
        ];
      }
      {
        job_name = "coral";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${builtins.toString coral.ports.node-exporter}"
              "127.0.0.1:${toString config.services.prometheus.exporters.dmarc.port}"
            ];
          }
        ];
      }
      {
        job_name = "gatus";
        scheme = "https";
        static_configs = [
          {
            targets = ["status.germond.org"];
          }
        ];
      }
      {
        job_name = "synapse";
        metrics_path = "/_synapse/metrics";
        static_configs = [
          {
            targets = ["10.100.10.2:${builtins.toString anemone.ports.matrix-synapse-monitoring}"];
          }
        ];
      }
      {
        job_name = "minio-job";
        metrics_path = "/minio/v2/metrics/cluster";
        scheme = "https";
        bearer_token_file = config.sops.secrets.minioBearerToken.path;
        static_configs = [
          {
            targets = ["s3.germond.org"];
          }
        ];
      }
      {
        job_name = "coral-f2b";
        scheme = "http";
        static_configs = [
          {
            targets = ["127.0.0.1:9191"];
          }
        ];
      }
      {
        job_name = "anemone-f2b";
        scheme = "http";
        static_configs = [
          {
            targets = ["${anemone.ips.vpn.A}:9191"];
          }
        ];
      }
    ];
  };

  systemd.services.grafana.serviceConfig = {
    # FIXME: Remove or keep ?
    # Without this grafana try to call sys_fchownat which is blocked without @chown;
    SystemCallFilter = ["@chown"];
  };

  users.users.promtail.extraGroups = ["nginx"];

  services.promtail = {
    configuration = {
      server.http_listen_port = coral.ports.promtail;
      server.grpc_listen_port = 0;

      clients = [
        {
          url = "http://${coral.ips.vpn.A}:${builtins.toString coral.ports.loki}/loki/api/v1/push";
        }
      ];

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
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
          ];
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

  networking.firewall.allowedTCPPorts = [coral.ports.loki];

  services.loki = {
    configuration = {
      auth_enabled = false;

      server.http_listen_port = coral.ports.loki;
      server.http_listen_address = coral.ips.vpn.A;

      ingester = {
        lifecycler = {
          address = coral.ips.vpn.A;
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
        # enforce_metric_name = false;
        allow_structured_metadata = false;
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };
    };
  };

  systemd.services."prometheus-dmarc-exporter".serviceConfig.DynamicUser = false;

  users.users."dmarc-exporter" = {
    isSystemUser = true;
    group = "dmarc-exporter";
  };

  users.groups."dmarc-exporter" = {};
}
