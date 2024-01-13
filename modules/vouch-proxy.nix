{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  yaml = pkgs.formats.yaml {};

  execCommand = "${cfg.package}/bin/vouch-proxy -config ${configPath}";

  cfg = config.services.vouch-proxy;

  configPath = yaml.generate "vouch-proxy-config.yml" cfg.settings;
in {
  options = {
    services.vouch-proxy = {
      enable = mkEnableOption "Vouch-Proxy";

      package = mkOption {
        type = types.package;
        default = pkgs.vouch-proxy;
        description = "Vouch-Proxy package.";
      };

      user = mkOption {
        type = types.str;
        default = "vouch-proxy";
        description = "User account under which vouch-proxy runs.";
      };

      group = mkOption {
        type = types.str;
        default = "vouch-proxy";
        description = "Group account under which vouch-proxy runs.";
      };

      envFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to an EnvironmentFile for the vouch-proxy service.
          The environment variables specified within can be used to configure or provide secrets
          while avoiding the nix store.
        '';
      };

      settings = mkOption {
        type = (pkgs.formats.yaml {}).type;
        default = {};
        description = "Configuration for vouch-proxy.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.user == "vouch-proxy") {
      vouch-proxy = {
        group = cfg.group;
        isSystemUser = true;
      };
    };

    users.groups = optionalAttrs (cfg.group == "vouch-proxy") {
      vouch-proxy = {};
    };

    systemd.services.vouch-proxy = {
      description = "Vouch Proxy - An SSO/OAuth solution for nginx auth_request.";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      stopIfChanged = false;
      startLimitIntervalSec = 60;
      serviceConfig = {
        ExecStart = execCommand;
        Restart = "always";
        RestartSec = "10s";
        # User and Group
        User = cfg.user;
        Group = cfg.group;
        EnvironmentFile = mkIf (cfg.envFile != null) cfg.envFile;
      };
    };
  };
}
