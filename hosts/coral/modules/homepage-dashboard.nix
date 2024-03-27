{
  pkgs,
  config,
  lib,
  infra,
  ...
}: let
  coral = infra.hosts.coral;
  yaml = pkgs.formats.yaml {};

  makeGermondLink = alias: "https://${alias}.germond.org";

  hp-services = [
    {
      Cloud = [
        {
          "Mon compte" = {
            icon = "keycloak";
            href = (makeGermondLink "newsso") + "/realms/germond/account";
            description = "Changer son mot de passe, son email, ...";
          };
        }
        {
          "Nextcloud - Stockage de fichier" = {
            icon = "nextcloud-blue";
            href = makeGermondLink "cloud";
            description = "Stockage de fichier similaire à Google Drive.";
            siteMonitor = makeGermondLink "cloud";
          };
        }
        {
          "PeerTube - Vidéos" = {
            icon = "peertube";
            href = makeGermondLink "videos";
            description = "Comme youtube mais les fichiers reste ici.";
          };
        }
        {
          "Hackmd - Notes collaborative" = {
            href = makeGermondLink "hackmd";
            description = "Notes collaborative.";
          };
        }
      ];
    }
    {
      Monitoring = [
        {
          Gatus = {
            icon = "gatus";
            href = makeGermondLink "status";
            description = "Surveille l'accessibilité des services.";
            widget = {
              type = "gatus";
              url = makeGermondLink "status";
            };
          };
        }
        {
          Prometheus = {
            icon = "prometheus";
            href = makeGermondLink "prometheus";
            description = "Agrège et stoque les métrics (CPU, RAM, I/O..).";
            widget = {
              type = "prometheus";
              url = "http://10.100.10.1:9001";
            };
          };
        }
        {
          AlertManager = {
            icon = "alertmanager";
            href = makeGermondLink "alert";
            description = "Envoi les alertes sur Telegram.";
          };
        }
        {
          Graphana = {
            icon = "grafana";
            href = makeGermondLink "grafana";
            description = "Affichage en graphique des données.";
          };
        }
      ];
    }
  ];
in {
  services.homepage-dashboard = {
    enable = true;
    package = pkgs.homepage-dashboard;
    listenPort = coral.ports.homepage-dashboard;
    settings = {
      title = "Germond Homelab";
      background = "https://images.unsplash.com/photo-1502790671504-542ad42d5189?auto=format&fit=crop&w=2560&q=80";
      cardBlur = "sm";
      theme = "dark";
      color = "zinc";
      iconStyle = "theme";
      statusStyle = "dot";

      language = "fr";

      target = "_blank"; # open links in new tabs

      hideVersion = true;
      disableCollapse = true;

      logpath = pkgs.linkFarm "homepage-dashboard-null-logs" {
        "logs/homepage.log" = "/dev/null";
      };
    };

    services = hp-services;

    kubernetes = {
      mode = "disabled";
    };
  };
}
