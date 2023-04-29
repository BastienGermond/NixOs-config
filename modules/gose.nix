{ config, lib, pkgs, ... }:

with lib;

let
  yaml = pkgs.formats.yaml { };

  cfg = config.services.gose;

  execCommand = "${cfg.package}/bin/gose -config ${defaultConfigPath}";

  defaultConfigPath = yaml.generate "config.yml" (removeNullAttrs cfg.config);

  markToRemoveFromSet = attrset: builtins.filter
    (
      attrname: (builtins.isNull (builtins.getAttr attrname attrset))
    )
    (builtins.attrNames attrset);

  removeNullAttrs = s: builtins.removeAttrs s (markToRemoveFromSet s);

  S3ServerSetupModule = {
    options = {
      bucket = mkOption {
        type = types.bool;
        default = true;
        description = "Create the bucket if it does not exist.";
      };

      cors = mkOption {
        type = types.bool;
        default = true;
        description = "Setup CORS rules for S3 bucket.";
      };

      lifecycle = mkOption {
        type = types.bool;
        default = true;
        description = "Setup lifecycle rules for object expiration.";
      };

      abort_incomplete_uploads = mkOption {
        type = types.ints.positive;
        default = 31;
        description = ''
          Number of days after which incomplete uploads are cleaned-up (set to 0 to disable).
        '';
      };
    };
  };

  serverExpirationModule = {
    options = {
      id = mkOption {
        type = types.str;
        description = "Identifier.";
      };

      title = mkOption {
        type = types.str;
        description = "Title.";
      };

      days = mkOption {
        type = types.str;
        description = "Number of days before expiration.";
      };
    };
  };

  S3ServerModule = {
    options = {
      endpoint = mkOption {
        type = types.str;
        description = "Hostname:Port of S3 server.";
      };

      bucket = mkOption {
        type = types.str;
        example = "gose-uploads";
        description = "Name of S3 bucket.";
      };

      region = mkOption {
        type = types.str;
        description = "Region of S3 server.";
      };

      path_style = mkOption {
        type = types.bool;
        default = false;
        description = "Prepend bucket name to path (required with minio).";
      };

      no_ssl = mkOption {
        type = types.bool;
        default = false;
        description = "Disable SSL encryption for S3.";
      };

      access_key = mkOption {
        type = types.str;
        description = "S3 Access Key.";
      };

      secret_key = mkOption {
        type = types.str;
        description = "S3 Secret Key.";
      };

      setup = mkOption {
        type = types.nullOr (types.submodule S3ServerSetupModule);
        default = null;
      };

      expiration = mkOption {
        type = types.nullOr (types.submodule serverExpirationModule);
        default = null;
      };

      part_size = mkOption {
        type = types.nullOr types.ints.positive;
        default = null;
      };

      implementation = mkOption {
        type = types.enum [ "AmazonS3" "MinIO" "UploadServer" "DigitalOceanSpaces" "" ];
        default = "";
      };
    };
  };
in
{
  options = {
    services.gose = {
      enable = mkEnableOption "Gose - A tera-scale file uploader";

      package = mkOption {
        type = types.package;
        default = pkgs.gose;
        description = "Gose package.";
      };

      user = mkOption {
        type = types.str;
        default = "gose";
        description = "User account under which gose runs.";
      };

      group = mkOption {
        type = types.str;
        default = "gose";
        description = "Group account under which gose runs.";
      };

      config = {
        listen = mkOption {
          type = types.str;
          default = ":8080";
          description = "The ip:port combination at which the backend should listen.";
        };

        base_url = mkOption {
          type = types.str;
          default = "http://localhost:8080";
          description = "The public facing address of the backend.";
        };

        static = mkOption {
          type = types.nullOr types.str;
          default = "./dist";
          description = "Directory of frontend assets if not bundled into the binary.";
          example = "./dist";
        };

        servers = mkOption {
          type = types.nullOr (types.listOf (types.submodule S3ServerModule));
          default = null;
          description = "Multiple server config.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable ({
    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = { };

    systemd.services.gose = {
      description = "Gose - A tera-scale file uploader";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      stopIfChanged = false;
      startLimitIntervalSec = 60;
      environment = {
        #   GATUS_CONFIG_PATH = cfg.configFile;
        GIN_MODE = "release";
      };
      serviceConfig = {
        ExecStart = execCommand;
        Restart = "always";
        RestartSec = "10s";
        # User and Group
        User = cfg.user;
        Group = cfg.group;
      };
    };
  });
}
