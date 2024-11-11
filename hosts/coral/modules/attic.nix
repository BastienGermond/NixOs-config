{
  config,
  lib,
  infra,
  ...
}: let
  coral = infra.hosts.coral;

  pgDbName = config.services.atticd.user;
  pgDbUser = config.services.atticd.user;
in {
  services.atticd = {
    enable = true;

    environmentFile = config.sops.secrets.atticCredentials.path;

    settings = {
      listen = "127.0.0.1:${builtins.toString coral.ports.attic}";
      allowed-hosts = ["cache.germond.org"];
      api-endpoint = "https://cache.germond.org/";

      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "1 year";
      };

      chunking = {
        nar-size-threshold = 64 * 1024; # 64 KiB
        min-size = 16 * 1024; # 16 KiB
        avg-size = 64 * 1024; # 64 KiB
        max-size = 256 * 1024; # 256 KiB
      };

      database.url = "postgres://${pgDbUser}@127.0.0.1:5432/${pgDbName}?sslmode=disable";

      storage = {
        type = "s3";
        region = "eu-west-3";
        bucket = "nix-cache";
        endpoint = "https://s3.germond.org/";
      };
    };
  };

  systemd.services.atticd.serviceConfig.DynamicUser = lib.mkForce false;

  users.users.${config.services.atticd.user} = {
    isSystemUser = true;
    group = config.services.atticd.group;
  };

  users.groups.${config.services.atticd.group} = {};

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = pgDbUser;
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [pgDbName];
  };

  services.postgresqlCipheredBackup.databases = [pgDbName];
}
