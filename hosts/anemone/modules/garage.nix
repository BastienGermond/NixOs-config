{
  config,
  pkgs,
  infra,
  lib,
  ...
}: let
  anemone = infra.hosts.anemone;
  domain = "germond.org";
in
  lib.mkMerge
  [
    {
      services.garage = {
        package = pkgs.garage_1_x;
        settings = {
          replication_factor = 1;
          rpc_bind_addr = "[::]:3901";
          rpc_public_addr = "127.0.0.1:3901";
          rpc_secret_file = config.sops.secrets.GarageRpcSecret.path;

          s3_api = {
            s3_region = "anemone";
            api_bind_addr = "[::]:${builtins.toString anemone.ports.garage-s3}";
            root_domain = "s3-garage.${domain}";
          };

          s3_web = {
            bind_addr = "[::]:${builtins.toString anemone.ports.garage-web}";
            root_domain = "web-garage.${domain}";
            index = "index.html";
          };

          data_dir = "/datastore/garage";
        };
      };
    }

    (lib.mkIf config.services.garage.enable {
      networking.firewall.allowedTCPPorts = [anemone.ports.garage-web anemone.ports.garage-s3];

      users.users.garage = {
        group = "garage";
        isSystemUser = true;
      };

      users.groups.garage = {};

      systemd.services.garage.serviceConfig.DynamicUser = false;
      systemd.services.garage.serviceConfig.User = "garage";
      systemd.services.garage.serviceConfig.Group = "garage";
    })
  ]
