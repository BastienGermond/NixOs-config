{
  infra,
  config,
  lib,
  ...
}: let
  anemone = infra.hosts.anemone;
in
  lib.mkMerge [
    {
      services.suwayomi-server = {
        group = "manga";
        dataDir = "/var/lib/suwayomi-server";
        settings = {
          server = {
            port = anemone.ports.suwayomi;
            extensionRepos = [
              "https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json"
            ];

            downloadAsCbz = true;
            systemTrayEnabled = false;

            settings = {
              server.webUIEnabled = true;
              server.webUIFlavor = "WebUI";
              server.webUIInterface = "browser";
              server.webUIChannel = "stable";
              server.webUIUpdateCheckInterval = 23;

              server.globalUpdateInterval = 12;
              server.updateMangas = false;

              server.initialOpenInBrowserEnabled = false;
              server.socksProxyEnabled = false;
            };
          };
        };
      };
    }

    (lib.mkIf config.services.suwayomi-server.enable {
      networking.firewall.allowedTCPPorts = [anemone.ports.suwayomi];
    })
  ]
