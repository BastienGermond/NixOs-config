{ config, pkgs, ... }:

{
  services.promtail = {
    enable = true;
    configuration = {
      server.http_listen_port = 3031;
      server.grpc_listen_port = 0;

      clients = [{
        url = "http://10.100.10.1:3100/loki/api/v1/push";
      }];

      scrape_configs = [{
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
      }];
    };
  };
}
