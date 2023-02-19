{ config, lib, pkgs, ... }:

let
  yaml = pkgs.formats.yaml { };

  cfg = config.services.gatus;

  execCommand = "${cfg.package}/bin/gatus";

  # cleanupEndpointDns = endpoint: if endpoint.dns.query-type == "" then builtins.removeAttrs endpoint [ "dns" ] else endpoint;
  # cleanupEndpointsDns = endpoints: builtins.map cleanupEndpointDns endpoints;
  # cleanupConfig = cfgGatus: builtins.mapAttrs (name: value: if name == "endpoints" then cleanupEndpointsDns value else value) cfgGatus;

  defaultConfigPath = yaml.generate "config.yml" cfg.config;

  uiButtonModule = {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Text to display on the button.";
      };

      link = lib.mkOption {
        type = lib.types.str;
        description = "Link to open when the button is clicked.";
      };
    };
  };

  uiModule = {
    options = {
      title = lib.mkOption {
        type = lib.types.str;
        default = "Health Dashboard ǀ Gatus";
        description = "Title of the document.";
      };

      description = lib.mkOption {
        type = lib.types.str;
        default = "Gatus is an advanced automated status page that lets you monitor your applications and configure alerts to notify you if there's an issue";
        description = "Meta description for the page.";
      };

      header = lib.mkOption {
        type = lib.types.str;
        default = "Health Status";
        description = "Header at the top of the dashboard.";
      };

      logo = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "URL to the logo to display.";
      };

      link = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Link to open when the logo is clicked.";
      };

      buttons = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule uiButtonModule);
        default = [ ];
      };
    };
  };

  endpointUiModule = {
    options = {
      hide-hostname = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to hide the hostname in the result.";
      };

      hide-url = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to ensure the URL is not displayed in the results. Useful if the URL contains a token.";
      };

      dont-resolve-failed-conditions = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to resolve failed conditions for the UI.";
      };

      # badge = lib.mkOption {
      #   type = lib.types.submodule {
      #     options = {
      #       response-time = lib.mkOption {
      #         type = lib.types.listOf lib.types.int;
      #         default = [ 50 200 300 500 750 ];
      #         description = ''
      #           List of response time thresholds.
      #           Each time a threshold is reached, the badge has a different color.
      #         '';
      #       };
      #     };
      #   };
      #   default = { };
      # };
    };
  };

  endpointModule = {
    options = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
        example = false;
        description = "Whether to monitor the endpoint.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        description = "Name of the endpoint. Can be anything.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Group name. Used to group multiple endpoints together on the dashboard.";
      };

      url = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "URL to send the request to.";
      };

      method = lib.mkOption {
        type = lib.types.str;
        default = "GET";
        description = "Request method.";
      };

      conditions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = lib.mdDoc "Conditions used to determine the health of the endpoint. See [Conditions](https://github.com/TwiN/gatus#conditions)";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "60s";
        description = "Duration to wait between every status check.";
      };

      graphql = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Whether to wrap the body in a query param (`{\"query\":\"$body\"}`).";
      };

      body = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Request body.";
      };

      headers = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Request headers.";
      };

      dns = lib.mkOption {
        type = lib.types.nullOr (lib.types.submodule {
          options = {
            query-type = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Query type (e.g. MX)";
            };

            query-name = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Query name (e.g. example.com)";
            };
          };
        });
        default = null;
        description = "Configuration for an endpoint of type DNS.";
      };

      ui = lib.mkOption {
        type = lib.types.submodule endpointUiModule;
        default = { };
        description = "UI configuration at the endpoint level.";
      };
    };
  };

  storageModule = {
    options = {
      path = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Path to persist the data in. Only supported for types sqlite and postgres.";
      };

      type = lib.mkOption {
        type = lib.types.enum [ "memory" "sqlite" "postgres" ];
        default = "memory";
        description = "Type of storage.";
      };

      caching = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to use write-through caching. Improves loading time for large dashboards.";
      };
    };
  };

  webModule = {
    options = {
      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address to listen on.";
      };

      port = lib.mkOption {
        type = lib.types.ints.positive;
        default = "8080";
        description = "Port to listen on.";
      };
    };
  };

  maintenanceModule = {
    options = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the maintenance period is enabled.";
      };

      start = lib.mkOption {
        type = lib.types.strMatching "[0-2]?[0-9]:[0-6][0-9]";
        example = "23:42";
        description = lib.mdDoc "Time at which the maintenance window starts in `hh:mm` format.";
      };

      duration = lib.mkOption {
        type = lib.types.str;
        example = "1h";
        description = "Duration of the maintenance window.";
      };

      every = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday" "Sunday" ]);
        default = [ ];
        example = "[\"Monday\" \"Thursday\"]";
        description = ''
          Days on which the maintenance period applies.
          If left empty, the maintenance window applies every day
        '';
      };
    };
  };
in
{
  options = {
    services.gatus = {
      enable = lib.mkEnableOption "Gatus Monitoring Dashboard";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.gatus;
        description = ''
          Gatus package.
        '';
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "gatus";
        description = "User account under which gatus runs.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "gatus";
        description = "Group account under which gatus runs.";
      };

      config = {
        debug = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to enable debug logs.";
        };

        metrics = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to expose metrics at /metrics.";
        };

        storage = lib.mkOption {
          type = lib.types.submodule storageModule;
          default = { };
          description = "Storage configuration.";
        };

        endpoints = lib.mkOption {
          type = lib.types.nonEmptyListOf (lib.types.submodule endpointModule);
          description = "List of endpoints to monitor.";
        };

        web = lib.mkOption {
          type = lib.types.submodule webModule;
          default = { };
          description = "Web configuration.";
        };

        ui = lib.mkOption {
          type = lib.types.submodule uiModule;
          default = { };
          description = "UI configuration.";
        };

        maintenance = lib.mkOption {
          type = lib.types.nullOr (lib.types.submodule maintenanceModule);
          default = null;
        };
      };

      configFile = lib.mkOption {
        type = lib.types.path;
        default = defaultConfigPath;
        description = ''
          A YAML configuration file can be used to configure Gatus, leaving this to default will fallback to use the nix `services.gatus.config` set.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable ({
    environment.systemPackages = [ cfg.package ];

    users.users.${cfg.user} = {
      group = cfg.group;
      isSystemUser = true;
    };

    users.groups.${cfg.group} = { };

    systemd.services.gatus = {
      description = "Gatus - Automated service health dashboard";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      stopIfChanged = false;
      startLimitIntervalSec = 60;
      environment = {
        GATUS_CONFIG_PATH = cfg.configFile;
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
