{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.transfer_sh;

  execCommand = "${cfg.package}/bin/transfer.sh";
in {
  options = {
    services.transfer_sh = {
      enable = lib.mkEnableOption "Transfer.sh";

      package = lib.mkOption {
        type = lib.types.package;
        description = "transfer.sh package.";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "transfer";
        description = "User account under which transfer.sh runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "transfer";
        description = "Group account under which transfer.sh runs.";
      };

      envFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''Environment file passed to the service.'';
      };

      config = {
        listener = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "port to use for http (:80)";
          example = ":80";
        };

        profile-listener = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "port to use for profiler (:6060)";
          example = ":6060";
        };

        force-https = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "redirect to https";
        };

        tls-listener = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "port to use for https";
          example = ":443";
        };

        tls-listener-only = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "flag to enable tls listener only";
          example = true;
        };

        tls-cert-file = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "path to tls certificate";
        };

        tls-private-key = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "path to tls private key";
        };

        http-auth-user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "user for basic http auth on upload";
        };

        http-auth-pass = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "pass for basic http auth on upload";
        };

        ip-whitelist = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
          description = "list of ips allowed to connect to the service";
        };

        ip-blacklist = lib.mkOption {
          type = lib.types.nullOr (lib.types.listOf lib.types.str);
          default = null;
          description = "list of ips not allowed to connect to the service";
        };

        temp-path = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "path to temp folder";
        };

        web-path = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "path to static web files (for development or custom front end)";
        };

        proxy-path = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "path prefix when service is run behind a proxy";
        };

        proxy-port = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "port of the proxy when the service is run behind a proxy";
        };

        email-contact = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "email contact for the front end";
        };

        ga-key = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "google analytics key for the front end";
        };

        provider = lib.mkOption {
          type = lib.types.enum ["s3" "storj" "gdrive" "local"];
          description = "which storage provider to use";
        };

        uservoice-key = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "user voice key for the front end";
        };

        aws-access-key = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "aws access key";
        };

        aws-secret-key = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "aws secret key";
        };

        bucket = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "aws bucket";
        };

        s3-endpoint = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Custom S3 endpoint.";
        };

        s3-region = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "region of the s3 bucket";
        };

        s3-no-multipart = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "disables s3 multipart upload";
        };

        s3-path-style = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Forces path style URLs, required for Minio.";
        };

        storj-access = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Access for the project";
        };

        storj-bucket = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Bucket to use within the project";
        };

        basedir = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "path storage for local/gdrive provider";
        };

        gdrive-client-json-filepath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "path to oauth client json config for gdrive provider";
        };

        gdrive-local-config-path = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "path to store local transfer.sh config cache for gdrive provider";
        };

        gdrive-chunk-size = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "chunk size for gdrive upload in megabytes, must be lower than available
          memory (8 MB)";
        };

        lets-encrypt-hosts = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "hosts to use for lets encrypt certificates (comma seperated)";
        };

        log = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "path to log file";
        };

        cors-domains = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "comma separated list of domains for CORS, setting it enable CORS";
        };

        clamav-host = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "host for clamav feature";
        };

        perform-clamav-prescan = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "prescan every upload through clamav feature (clamav-host must be a local
          clamd unix socket)";
        };

        rate-limit = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "request per minute";
        };

        max-upload-size = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "max upload size in kilobytes";
        };

        purge-days = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "number of days after the uploads are purged automatically";
        };

        purge-interval = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "interval in hours to run the automatic purge for (not applicable to S3 and
          Storj)";
        };

        random-token-length = lib.mkOption {
          type = lib.types.nullOr lib.types.int;
          default = null;
          description = "length of the random token for the upload path (double the size for delete
          path)";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      toStr = e:
        if e == null
        then ""
        else
          (
            if builtins.isBool e
            then
              (
                if e == true
                then "true"
                else "false"
              )
            else
              (
                if builtins.isList e
                then (builtins.concatStringsSep "," e)
                else (builtins.toString e)
              )
          );

      buildFlags = transferCfg:
        builtins.concatStringsSep " "
        (
          builtins.attrValues (
            builtins.mapAttrs (name: value:
              if value == null
              then ""
              else "--${name}=\"${toStr value}\"")
            transferCfg
          )
        );
    in {
      users.users.${cfg.user} = {
        group = cfg.group;
        isSystemUser = true;
      };

      users.groups.${cfg.group} = {};

      systemd.services."transfer.sh" = {
        description = "Transfer.sh -  Easy and fast file sharing from the command-line.";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        stopIfChanged = false;
        startLimitIntervalSec = 60;

        serviceConfig =
          {
            ExecStart = "${execCommand} ${buildFlags cfg.config}";
            Restart = "always";
            RestartSec = "10s";
            # User and Group
            User = cfg.user;
            Group = cfg.group;
            # Transfer sh uses the tmp so let's isolate it
            PrivateTmp = "yes";
          }
          // (
            if (cfg.envFile != null)
            then {
              EnvironmentFile = cfg.envFile;
            }
            else {}
          );
      };
    }
  );
}
