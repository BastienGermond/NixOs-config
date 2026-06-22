{
  my,
  lib,
  fileSystems,
  ...
}: {
  programs.waybar = {
    enable = my.windowManager.sway.enable;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 18;
      spacing = 6;

      modules-left = ["sway/workspaces"];
      modules-center = [];
      modules-right =
        [
          "disk#root"
        ]
        ++ lib.optionals (fileSystems ? "/home") ["disk#home"]
        ++ [
          "network"
          "cpu"
          "memory"
        ]
        # ++ my.networking.wirelessInterfaces
        ++ [
          "clock"
          "pulseaudio"
          "custom/notifications"
          "temperature"
          "battery"
          "tray"
        ];

      "sway/workspaces" = {
        all-outputs = false;
        sort-by-number = true;
      };

      network = {
        format = "{ifname} {ipaddr}";
        format-wifi = " {essid} ({signalStrength}%) - {ipaddr}";
        format-ethernet = "󰊗 {ipaddr}/{cidr}";
      };

      cpu = {
        interval = 2;
        format = "cpu {usage}%";
      };

      memory = {
        interval = 2;
        format = "RAM {percentage}%";
      };

      "disk#root" = {
        path = "/";
        interval = 30;
        format = " {free}";
      };

      "disk#home" = lib.mkIf (fileSystems ? "/home") {
        path = "/home";
        interval = 30;
        format = " {free}";
      };

      clock = {
        interval = 1;
        format = " {:%Y-%m-%d %H:%M:%S}";
      };

      pulseaudio = {
        format = "VOL {volume}%";
        format-muted = "muted";
      };

      temperature = {
        # thermal-zone = 0;
        critical-threshold = 85;
        format = "{temperatureC}°C";
      };

      battery = {
        format = "{capacity}%";
        format-charging = " {capacity}%";
        format-full = " {capacity}%";
      };

      tray = {
        # icon-size = 10;
        spacing = 5;
      };

      "custom/notifications" = {
        format = "{}";
        interval = 3;

        exec = ''
          if makoctl mode | grep -q do-not-disturb; then
            echo ""
          else
            echo ""
          fi
        '';

        on-click = ''
          if makoctl mode | grep -q do-not-disturb; then
            makoctl mode -r do-not-disturb
          else
            makoctl mode -a do-not-disturb
          fi
        '';

        tooltip = false;
      };
    };

    style =
      # css
      ''
        * {
          font-family: FiraMono Nerd Font, monospace;
          font-size: 16px;
        }

        window#waybar {
          background: #222;
          color: #dfdfdf;
          transition-duration: .5s;
        }

        #workspaces button {
          color: #aaa;
          padding: 1px 5px;
          border-bottom: 2px solid #222;
        }

        #workspaces button.focused {
          color: #444;
          background: #999;
          border-bottom: 2px solid #ffb52a;
        }

        #workspaces button.urgent {
            background-color: #eb4d4b;
        }

        #custom-notifications {
          color: #fabd2f;
          padding-right: 8px;
        }

        #cpu { border-bottom: 2px solid #f90000; }
        #memory { border-bottom: 2px solid #4bffdc; }
        #clock { border-bottom: 2px solid #0a6cf5; }
        #temperature { border-bottom: 2px solid #f50a4d; }
      '';
  };
}
