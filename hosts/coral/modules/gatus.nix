{ config, pkgs, lib, ... }:

{
  services.gatus = {
    enable = true;
    config = {
      web = {
        address = "127.0.0.1";
        port = 8040;
      };
      storage = {
        type = "postgres";
        path = "postgres://gatus@127.0.0.1:5432/gatus?sslmode=disable";
      };
      ui = {
        title = "Germond's Infrastructure Monitoring";
        description = "Monitoring of my infrastructure, mostly under domain germond.org.";
        logo = "https://s3.germond.org/gatus/serveur-meduse.png";
      };
      endpoints = [
        {
          name = "Authentik";
          group = "Authentication";
          url = "https://sso.germond.org/-/health/ready/";
          conditions = [
            "[STATUS] == 204"
          ];
        }
        {
          name = "Nextcloud";
          group = "Cloud";
          url = "https://cloud.germond.org/heartbeat";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Grafanouille";
          group = "Others";
          url = "https://grafana.germond.org";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "S3";
          group = "Others";
          url = "https://s3.germond.org/minio/health/live";
          conditions = [
            "[STATUS] == 200"
          ];
        }
      ];
    };
  };

  services.postgresql.ensureDatabases = [ "gatus" ];
  services.postgresql.ensureUsers = [
    {
      name = "gatus";
      ensurePermissions = {
        "DATABASE \"gatus\"" = "ALL PRIVILEGES";
      };
    }
  ];
}
