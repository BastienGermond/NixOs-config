{ config, lib, pkgs, ... }:

let
  cfg = config.services.authentik;

  toStrBool = value: if value == true then "true" else "false";
in
{
  options = {
    services.authentik = {
      enable = lib.mkEnableOption "Authentik Service";

      image = lib.mkOption {
        type = lib.types.str;
        default = "ghcr.io/goauthentik/server";
        example = lib.literalExpression "ghcr.io/goauthentik/server";
        description = ''
          Authentik container image. Default uses github image.
        '';
      };

      version = lib.mkOption {
        type = lib.types.str;
        default = "2022.7.3";
        example = lib.literalExpression "2022.7.3";
        description = ''
          Authentik version to use. https://github.com/goauthentik/authentik/releases
        '';
      };

      postgresBackup = {
        enable = lib.mkEnableOption "Postgres Backup service";
        location = lib.mkOption {
          type = lib.types.path;
          default = "/var/backup/postgresql";
          example = lib.literalExpression "/var/backup/postgresql";
          description = ''
            Path of directory where the PostgreSQL database dumps will be placed.
          '';
        };
      };

      GeoIP = {
        enable = lib.mkEnableOption "GeoIP Support";
      };

      dbUser = lib.mkOption {
        type = lib.types.str;
        default = "authentik";
        example = lib.literalExpression "authentik";
        description = ''
          Postgres user used for to connect to the database.
        '';
      };

      dbName = lib.mkOption {
        type = lib.types.str;
        default = "authentik";
        example = lib.literalExpression "authentik";
        description = ''
          Postgres database name.
        '';
      };

      config = {
        mediaFolder = lib.mkOption {
          type = lib.types.str;
          default = "media";
          description = ''
            Authentik media folder. Leaving the default value will create a docker volume.
          '';
        };

        certsFolder = lib.mkOption {
          type = lib.types.str;
          default = "certs";
          description = ''
            Authentik certs folder. Leaving the default value will create a docker volume.
          '';
        };

        logLevel = lib.mkOption {
          type = lib.types.enum [ "debug" "info" "warning" "error" ];
          default = "info";
          description = ''
            Log level for the server and worker containers. Possible values: debug, info, warning, error
          '';
        };

        errorReportingEnable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Enable error reporting. Defaults to false.

            Error reports are sent to https://sentry.beryju.org, and are used for debugging and general feedback. Anonymous performance data is also sent.
          '';
        };

        disableStartupAnalytics = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Disable sending anonymous analytics on startup.
          '';
        };
      };

      authentikServerEnvironmentFiles = lib.mkOption {
        type = with lib.types; listOf path;
        default = [ ];
        description = ''
          EnvironmentFiles passed to server and worker container. Mostly used to pass secrets such
          as AUTHENTIK_SECRET_KEY or AUTHENTIK_POSTGRESQL__PASSWORD.
        '';
      };
    };

  };


  config = lib.mkIf cfg.enable (
    let
      authentikContainersEnv = {
        AUTHENTIK_REDIS__HOST = "localhost";

        AUTHENTIK_LOG_LEVEL = cfg.config.logLevel;

        AUTHENTIK_POSTGRESQL__HOST = "localhost";
        AUTHENTIK_POSTGRESQL__USER = cfg.dbUser;
        AUTHENTIK_POSTGRESQL__NAME = cfg.dbName;

        AUTHENTIK_ERROR_REPORTING__ENABLED = toStrBool cfg.config.errorReportingEnable;

        AUTHENTIK_DISABLE_STARTUP_ANALYTICS = toStrBool cfg.config.disableStartupAnalytics;
      };

      authentikCommonVolumes = lib.mkMerge [
        [ "${cfg.config.mediaFolder}:/media" ]
        (lib.mkIf
          cfg.GeoIP.enable [
          "${config.services.geoipupdate.settings.DatabaseDirectory}:/geoip"
        ])
      ];

    in
    lib.mkMerge [
      ({
        # PostgreSQL DB
        services.postgresql = {
          enable = true;
          enableTCPIP = true;
          authentication = lib.mkOverride 10 ''
            local all all trust
            host all all 127.0.0.1/32 trust
            host all all ::1/128 trust
          '';
          ensureUsers = [
            {
              name = cfg.dbUser;
              ensurePermissions = {
                "DATABASE \"${cfg.dbName}\"" = "ALL PRIVILEGES";
              };
            }
          ];
          ensureDatabases = [ cfg.dbName ];
        };

        # Redis
        services.redis.servers.redis-authentik = {
          enable = true;
          port = 6379;
        };

        virtualisation.oci-containers = {
          backend = "docker";

          containers = lib.mkMerge [
            ({
              authentik-server = {
                autoStart = true;
                # user = "root";
                image = "${cfg.image}:${cfg.version}";
                cmd = [ "server" ];
                extraOptions = [ "--network=host" ];
                environment = authentikContainersEnv;
                environmentFiles = cfg.authentikServerEnvironmentFiles;
                volumes = authentikCommonVolumes;
              };

              authentik-worker = {
                autoStart = true;
                # Must access docker socket.
                user = "root";
                image = "${cfg.image}:${cfg.version}";
                cmd = [ "worker" ];
                extraOptions = [ "--network=host" ];
                environment = authentikContainersEnv;
                environmentFiles = cfg.authentikServerEnvironmentFiles;
                volumes = lib.mkMerge [
                  authentikCommonVolumes
                  [
                    "/var/run/docker.sock:/var/run/docker.sock"
                    "${cfg.config.certsFolder}:/certs"
                  ]
                ];
              };
            })
          ];
        };
      })

      (lib.mkIf cfg.postgresBackup.enable {
        services.postgresqlBackup = {
          enable = true;
          location = cfg.postgresBackup.location;
          databases = [ cfg.dbName ];
        };
      })

      (lib.mkIf cfg.GeoIP.enable {
        services.geoipupdate = {
          enable = true;
        };
      })
    ]
  );
}
