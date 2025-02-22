{
  config,
  pkgs,
  infra,
  ...
}: let
  coral = infra.hosts.coral;
  anemone = infra.hosts.anemone;
in {
  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd" "processes" "cpu"];
        listenAddress = anemone.ips.vpn.A;
        port = anemone.ports.node-exporter;
      };

      systemd = {
        enable = true;
        listenAddress = anemone.ips.vpn.A;
        openFirewall = true;
        port = anemone.ports.systemd-exporter;
      };
    };
  };

  services.promtail = {
    configuration = {
      server.http_listen_port = anemone.ports.promtail;
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
      ];
    };
  };

  services.cadvisor = {
    listenAddress = anemone.ips.vpn.A;
    port = anemone.ports.cadvisor;
  };

  networking.firewall.allowedTCPPorts = [anemone.ports.cadvisor];
}
