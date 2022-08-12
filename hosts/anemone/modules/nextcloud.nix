{ config, pkgs, ... }:

{
  config = {
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {
            "DATABASE \"nextcloud\"" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "nextcloud" ];
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud24;
      hostName = "cloud.germond.org";
      home = "/datastore/nextcloud";
      https = true;

      config = {
        dbuser = "nextcloud";
        dbtype = "pgsql";
        dbport = 5432;
        dbname = "nextcloud";
        dbhost = "localhost";

        overwriteProtocol = "https";

        adminpassFile = config.sops.secrets.nextcloudAdminPass.path;
      };
    };
  };
}
