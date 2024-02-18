{
  config,
  pkgs,
  lib,
  ...
}: {
  services.gatus = {
    enable = true;
    config = {
      metrics = true;
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
        # {
        #   name = "Authentik";
        #   group = "0 - Authentication";
        #   url = "https://sso.germond.org/-/health/ready/";
        #   conditions = [
        #     "[STATUS] == 204"
        #   ];
        # }
        {
          name = "Keycloak";
          group = "0 - Authentication";
          url = "https://newsso.germond.org/health/ready";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Nextcloud";
          group = "1 - Cloud";
          url = "https://cloud.germond.org/heartbeat";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Gitea";
          group = "2 - Services";
          url = "https://git.germond.org/api/healthz";
          conditions = [
            "[STATUS] == 200"
            "[BODY].status == pass"
          ];
        }
        {
          name = "Hedgedoc";
          group = "2 - Services";
          url = "https://hackmd.germond.org/";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Transfer.sh";
          group = "2 - Services";
          url = "https://t.germond.org/health.html";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Grafanouille";
          group = "2 - Services";
          url = "https://grafana.germond.org";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Synapse (Matrix)";
          group = "2 - Services";
          url = "https://germond.org/matrix/health";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Germond Tube";
          group = "2 - Services";
          url = "https://videos.germond.org";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "S3";
          group = "3 - Others";
          url = "https://s3.germond.org/minio/health/live";
          conditions = [
            "[STATUS] == 200"
          ];
        }
      ];
    };
  };

  services.postgresql.ensureDatabases = ["gatus"];
  services.postgresql.ensureUsers = [
    {
      name = "gatus";
      ensureDBOwnership = true;
    }
  ];

  services.postgresqlCipheredBackup.databases = ["gatus"];

  systemd.services.gatus = {
    after = ["postgresql.service"];
    bindsTo = ["postgresql.service"];
  };
}
