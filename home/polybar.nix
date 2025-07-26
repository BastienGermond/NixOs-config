{
  pkgs,
  fileSystems,
  lib,
  config,
  my,
  ...
}: {
  services.polybar = {
    enable = my.i3.enable;
    package = pkgs.polybarFull;
    script = ''
      # Find the right thermal zone number
      for thermal in /sys/class/thermal/thermal_zone*; do
          if [ "$(${pkgs.toybox}/bin/cat "$thermal/type")" = 'acpitz' ]; then
              CPU_THERMAL_ZONE=$(echo $thermal | ${pkgs.toybox}/bin/sed 's/\/sys\/class\/thermal\/thermal_zone//')
              break;
          fi
      done

      if [ -z "$CPU_THERMAL_ZONE" ]; then
          echo "Coudn't find cpu thermal zone"
          exit 1
      fi

      export BATTERY=$(${pkgs.toybox}/bin/basename "$(${pkgs.toybox}/bin/find /sys/class/power_supply/ -maxdepth 1 -name 'BAT*' | ${pkgs.toybox}/bin/head -n1)")
      export ADAPTER=$(${pkgs.toybox}/bin/basename "$(${pkgs.toybox}/bin/find /sys/class/power_supply/ -maxdepth 1 -name 'AC*' | ${pkgs.toybox}/bin/head -n1)")
      export CPU_THERMAL_ZONE=$CPU_THERMAL_ZONE

      # Run polybar on every connected monitor.
      for m in $(${pkgs.xorg.xrandr}/bin/xrandr --query | \
                 ${pkgs.gnugrep}/bin/grep " connected" | \
                 ${pkgs.coreutils}/bin/cut -d" " -f1); do
        MONITOR=$m polybar default &
      done
    '';
    settings = let
      mkWlanModule = interface: {
        "module/${interface}" = {
          type = "internal/network";
          inherit interface;
          interval = 3.0;

          format-connected = "<label-connected>";
          format-connected-underline = "#9f78e1";
          label-connected = "%essid% (%local_ip%)";

          format-disconnected = "";
        };
      };

      wlanModules = builtins.foldl' (acc: interface: acc // mkWlanModule interface) {} my.wirelessInterfaces;
    in
      wlanModules
      // {
        "colors" = {
          background = "\${xrdb:color0:#222}";
          background-alt = "#999";
          foreground = "#dfdfdf";
          foreground-alt = "#999";
          primary = "#ffb52a";
          secondary = "#e60053";
          alert = "#bd2c40";
          white = "#fff";
        };
        "settings" = {
          screenchange-reload = true;
        };
        "bar/default" = {
          monitor = "\${env:MONITOR:}";
          width = "100%";
          height = 30;
          radius = 0;
          fixed-center = false;

          background = "\${colors.background}";
          foreground = "\${colors.foreground}";

          line-size = 3;
          line-color = "#f00";

          border-top-size = 1;
          border-color = "\${colors.background}";

          padding-left = 0;
          padding-right = 0;
          padding-top = 3;
          padding-bottom = 2;

          module-margin-left = 1;
          module-margin-right = 0;

          font-0 = "FiraMono Nerd Font:size=14";
          font-1 = "unifont:fontformat=truetype:size=14:antialias=false;0";

          modules-left = "i3";
          modules-center = "";
          modules-right = "rootfs ${lib.optionalString (fileSystems ? "/home") "homefs"} cpu memory ${(lib.strings.concatStringsSep " " my.wirelessInterfaces)} date pulseaudio temperature dunst battery tray";

          scroll-up = "i3.next";
          scroll-down = "i3.prev";

          cursor-click = "pointer";
          cusror-scroll = "ns-resize";

          enable-ipc = true;
        };
        "global/wm" = {
          margin-top = 5;
          margin-bottom = 5;
        };
        "module/cpu" = {
          type = "internal/cpu";
          interval = 2;
          format-prefix = "cpu ";
          format-prefix-foreground = "\${colors.white}";
          format-underline = "#f90000";
          label = "%percentage:2%%";
        };
        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format-prefix = "RAM ";
          format-prefix-foreground = "\${colors.foreground-alt}";
          format-underline = "#4bffdc";
          label = "%percentage_used%%";
        };
        "module/rootfs" = {
          type = "internal/fs";
          interval = 25;
          "mount-0" = "/";
          label-mounted = "  %free%";
          label-unmounted = "%mountpoint% not mounted";
          label-unmounted-foreground = "\${colors.foreground-alt}";
        };
        "module/homefs" = {
          type = "internal/fs";
          interval = 25;
          "mount-0" = "/home";
          label-mounted = "  %free%";
          label-unmounted = "%mountpoint% not mounted";
          label-unmounted-foreground = "\${colors.foreground-alt}";
        };
        "module/date" = {
          type = "internal/date";
          interval = 5;
          date = " %Y-%m-%d%";
          date-alt = " %Y-%m-%d%";
          time = "%H:%M:%S";
          time-alt = "%H:%M:%S";
          format-prefix = " ";
          format-prefix-foreground = "\${colors.foreground-alt}";
          format-underline = "#0a6cf5";
          label = "%date% %time%";
        };
        "module/pulseaudio" = {
          type = "internal/pulseaudio";
          format-volume = "<label-volume> <bar-volume>";
          label-volume = "VOL %percentage%%";
          label-volume-foreground = "\${root.foreground}";
          label-muted = "muted";
          label-muted-foreground = "#666";
          bar-volume-width = 10;
          bar-volume-foreground-0 = "#55aa55";
          bar-volume-foreground-1 = "#55aa55";
          bar-volume-foreground-2 = "#55aa55";
          bar-volume-foreground-3 = "#55aa55";
          bar-volume-foreground-4 = "#55aa55";
          bar-volume-foreground-5 = "#f5a70a";
          bar-volume-foreground-6 = "#ff5555";
          bar-volume-gradient = false;
          bar-volume-indicator = "|";
          bar-volume-indicator-font = 2;
          bar-volume-fill = "─";
          bar-volume-fill-font = 2;
          bar-volume-empty = "─";
          bar-volume-empty-font = 2;
          bar-volume-empty-foreground = "\${colors.foreground-alt}";
        };
        "module/battery" = {
          type = "internal/battery";
          battery = "\${env:BATTERY:BAT0}";
          adapter = "\${env:ADAPTER:ADP1}";
          full-at = 90;
          format-charging = "<animation-charging> <label-charging>";
          format-charging-underline = "#ffb52a";
          label-charging = "%percentage%%";
          format-discharging = "<label-discharging>";
          format-discharging-underline = "\${self.format-charging-underline}";
          label-discharging = " %percentage%%";
          format-full-prefix = " ";
          format-full-prefix-foreground = "\${colors.foreground-alt}";
          format-full-underline = "\${self.format-charging-underline}";
          animation-charging-0 = " ";
          animation-charging-1 = " ";
          animation-charging-2 = " ";
          animation-charging-3 = " ";
          animation-charging-4 = " ";
          animation-charging-foreground = "\${colors.white}";
          animation-charging-framerate = 700;
        };
        "module/temperature" = {
          type = "internal/temperature";
          thermal-zone = "\${env:CPU_THERMAL_ZONE:6}";
          base-temperature = 45;
          warn-temperature = 70;
          format = "<ramp> <label>";
          format-underline = "#f50a4d";
          format-warn = "<ramp> <label-warn>";
          format-warn-underline = "\${self.format-underline}";
          label = "%temperature-c%";
          label-warn = "%temperature-c%";
          label-warn-foreground = "\${colors.secondary}";
          ramp-0 = " ";
          ramp-1 = "";
          ramp-2 = "";
          ramp-foreground = "\${colors.white}";
        };
        # "module/eth" = {
        #   type = "internal/network";
        #   interface = "enp1s0f0";
        #   interval = 3.0;

        #   format-connected-underline = "#55aa55";
        #   format-connected-prefix = "ETH ";
        #   format-connected-prefix-foreground = "\${colors.foreground-alt}";
        #   label-connected = "%local_ip%";

        #   format-disconnected = "";
        # };
        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:30:...%";
        };
        "module/xkeyboard" = {
          type = "internal/xkeyboard";
          blacklist-0 = "num lock";

          format-prefix = " ";
          format-prefix-foreground = "\${colors.foreground-alt}";
          format-prefix-underline = "\${colors.secondary}";

          label-layout = "%layout%";
          label-layout-underline = "\${colors.secondary}";

          label-indicator-padding = 2;
          label-indicator-margin = 1;
          label-indicator-background = "\${colors.secondary}";
          label-indicator-underline = "\${colors.secondary}";
        };
        "module/i3" = {
          type = "internal/i3";
          format = "<label-state> <label-mode>";
          index-sort = true;
          wrapping-scroll = false;

          # Only show workspaces on the same output as the bar
          pin-workspaces = true;

          label-mode-padding = 1;
          label-mode-foreground = "#000";
          label-mode-background = "\${colors.primary}";

          label-focused = "%name%";
          label-focused-background = "\${colors.background-alt}";
          label-focused-underline = "\${colors.primary}";
          label-focused-padding = 1;

          label-unfocused = "%name%";
          label-unfocused-padding = 1;

          label-visible = "%name%";
          label-visible-background = "\${self.label-focused-background}";
          label-visible-underline = "\${self.label-focused-underline}";
          label-visible-padding = "\${self.label-focused-padding}";

          label-urgent = "%name%";
          label-urgent-background = "\${colors.alert}";
          label-urgent-padding = 1;

          label-separator = "|";
        };
        "module/tray" = {
          type = "internal/tray";
          tray-padding = 0;
          tray-spacing = 2;
          tray-size = "80%";
          # tray-background = "#0063ff";
        };
        "module/dunst" = {
          type = "custom/ipc";
          initial = 1;
          format-foreground = "\${colors.primary}";
          hook = [
            "echo \"%{A1:${pkgs.dunst}/bin/dunstctl set-paused true && polybar-msg hook dunst 2:} %{A}\""
            "echo \"%{A1:${pkgs.dunst}/bin/dunstctl set-paused false && polybar-msg hook dunst 1:} %{A}\""
          ];
        };
      };
  };
}
