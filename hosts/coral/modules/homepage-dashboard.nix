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
          Nextcloud = {
            icon = "nextcloud-blue";
            href = makeGermondLink "cloud";
            description = "Stockage de fichier similaire de Google Drive.";
          };
        }
        {
          PeerTube = {
            icon = "peertube";
            href = makeGermondLink "videos";
            description = "Comme youtube mais les fichiers reste ici.";
          };
        }
        {
          Hackmd = {
            href = makeGermondLink "hackmd";
            description = "Notes colaboratives.";
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
          };
        }
        {
          Prometheus = {
            icon = "prometheus";
            href = makeGermondLink "prometheus";
            description = "Agrège et stoque les métrics (CPU, RAM, I/O..).";
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
  };

  systemd.services.homepage-dashboard.environment.HOMEPAGE_CONFIG_DIR = let
    configDir = pkgs.linkFarm "homepage-dashboard-config" {
      "settings.yaml" = yaml.generate "settings.yaml" {
        title = "Germond Homelab";
        cardBlur = "sm";
        theme = "dark";
        color = "slate";
        iconStyle = "theme";

        language = "fr";

        target = "_blank"; # open links in new tabs

        hideVersion = true;
        disableCollapse = true;

        logpath = pkgs.linkFarm "homepage-dashboard-null-logs" {
          "logs/homepage.log" = "/dev/null";
        };
      };
      "services.yaml" = yaml.generate "services.yaml" hp-services;
      "widgets.yaml" = yaml.generate "widgets.yaml" [];
      "bookmarks.yaml" = yaml.generate "bookmarks.yaml" [];
      "docker.yaml" = yaml.generate "docker.yaml" {};
      "kubernetes.yaml" = yaml.generate "kubernetes.yaml" {
        mode = "disabled";
      };
      "custom.css" = pkgs.writeText "custom.css" '''';
      "custom.js" = pkgs.writeText "custom.js" '''';
    };
  in
    lib.mkForce "${configDir}";
}