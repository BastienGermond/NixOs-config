{
  config,
  pkgs,
  ...
}: let
  polybar-wg = pkgs.writeShellScript "polybar-wg.sh" ''
    # https://github.com/polybar/polybar/wiki/Formatting#format-tags-inside-polybar-config
    green=#55aa55

    connected_interface="wg0"
    ip=$(${pkgs.iproute2}/bin/ip a show "$connected_interface" | ${pkgs.toybox}/bin/grep inet | ${pkgs.gawk}/bin/awk '{ print $2 }' | ${pkgs.toybox}/bin/cut -d '/' -f 1)

    print() {
        if [[ -n "$connected_interface" ]]
        then
            echo %{u"$green"}%{+u}%{F"$green"}󰒄 %{F-}" $connected_interface $ip"
        else
            echo %{u"$green"}%{+u}%{F"$green"}󰒄 %{F-}" wg nc."
        fi
    }

    case "$1" in
        *)
            print
            ;;
    esac
  '';
in {
  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    config = ../../../dotfiles/polybar/config;
    script = ''
      # Terminate already running bar instances
      # ${pkgs.toybox}/bin/pkill polybar

      # Wait until the processes have been shut down
      # while ${pkgs.toybox}/bin/pgrep -u $UID -x polybar >/dev/null; do ${pkgs.toybox}/bin/sleep 1; done

      # Find the right thermal zone number
      for thermal in /sys/class/thermal/thermal_zone*; do
          if [ "$(${pkgs.toybox}/bin/cat "$thermal/type")" = 'x86_pkg_temp' ]; then
              CPU_THERMAL_ZONE=$(echo $thermal | ${pkgs.toybox}/bin/sed 's/\/sys\/class\/thermal\/thermal_zone//')
              break;
          fi
      done

      if [ -z "$CPU_THERMAL_ZONE" ]; then
          echo "Coudn't find cpu thermal zone"
          exit 1
      fi

      export CPU_THERMAL_ZONE=$CPU_THERMAL_ZONE

      # Run polybar on every connected monitor.
      for m in $(${pkgs.xrandr}/bin/xrandr --query | \
                 ${pkgs.gnugrep}/bin/grep " connected" | \
                 ${pkgs.coreutils}/bin/cut -d" " -f1); do
        MONITOR=$m polybar default &
      done
    '';
    settings = {
      "bar/default" = {
        monitor = "\${env:MONITOR:}";
        width = "100%";
        radius = 0;
        fixed-center = false;

        background = "\${colors.background}";
        foreground = "\${colors.foreground}";

        line-size = 3;
        line-color = "#f00";

        border-size = 0;
        border-color = "#000";

        padding-left = 0;
        padding-right = 0;

        module-margin-left = 1;
        module-margin-right = 0;

        font-0 = "FiraMono Nerd Font";
        font-1 = "unifont:fontformat=truetype:size=8:antialias=false;0";

        modules-left = "i3";
        modules-center = "";
        modules-right = "nixosfs homefs eth cpu memory wireguard wlan date pulseaudio temperature dunst battery tray";

        scroll-up = "i3.next";
        scroll-down = "i3.prev";

        cursor-click = "pointer";
        cusror-scroll = "ns-resize";

        enable-ipc = true;
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:30:...%";
      };
      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";

        format-prefix = " ";
        format-prefix-foreground = "\$\$colors.foreground-alt}";
        format-prefix-underline = "\$\$colors.secondary}";

        label-layout = "%layout%";
        label-layout-underline = "\$\$colors.secondary}";

        label-indicator-padding = 2;
        label-indicator-margin = 1;
        label-indicator-background = "\$\$colors.secondary}";
        label-indicator-underline = "\$\$colors.secondary}";
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
        label-mode-background = "\$\$colors.primary}";

        label-focused = "%name%";
        label-focused-background = "\$\$colors.background-alt}";
        label-focused-underline = "\$\$colors.primary}";
        label-focused-padding = 1;

        label-unfocused = "%name%";
        label-unfocused-padding = 1;

        label-visible = "%name%";
        label-visible-background = "\$\$self.label-focused-background}";
        label-visible-underline = "\$\$self.label-focused-underline}";
        label-visible-padding = "\$\$self.label-focused-padding}";

        label-urgent = "%name%";
        label-urgent-background = "\$\$colors.alert}";
        label-urgent-padding = 1;

        label-separator = "|";
      };
      "module/homefs" = {
        type = "internal/fs";
        interval = 25;

        mount-0 = "/home";

        label-mounted = "  %free%";
        label-unmounted = "%mountpoint% not mounted";
        label-unmounted-foreground = "\$\$colors.foreground-alt}";
      };
      "module/wireguard" = {
        type = "custom/script";
        exec = "${polybar-wg} ";
        tail = false;
        interval = 5;
      };
      "module/tray" = {
        type = "internal/tray";
        tray-padding = 0;
        tray-spacing = 2;
        tray-size = "80%";
        # tray-background = "#0063ff";
      };
      # "module/spotibar-previous-track" = {
      #   type = "custom/script";
      #   exec = "echo ";
      #   click-left = "${pkgs.spotibar}/bin/spotibar --previous-track";
      #   exec-if = "[ $(${pkgs.spotibar}/bin/spotibar --is-live) = \"True\" ]";
      #   format-underline = "#1db954";
      #   format-padding = 1;
      # };
      # "module/spotibar-currently-playing" = {
      #   type = "custom/script";
      #   exec = "${pkgs.spotibar}/bin/spotibar --get-currently-playing";
      #   click-right = "${pkgs.spotibar}/bin/spotibar --toggle-playback";
      #   exec-if = "[ $(${pkgs.spotibar}/bin/spotibar --is-live) = \"True\" ]";
      #   format-underline = "#1db954";
      #   format-padding = 0;
      # };
      # "module/spotibar-next-track" = {
      #   type = "custom/script";
      #   exec = "echo ";
      #   click-left = "${pkgs.spotibar}/bin/spotibar --next-track";
      #   exec-if = "[ $(${pkgs.spotibar}/bin/spotibar --is-live) = \"True\" ]";
      #   format-underline = "#1db954";
      #   format-padding = 1;
      # };
      "module/dunst" = {
        type = "custom/ipc";
        initial = 1;
        format-foreground = "\$\$colors.primary}";
        hook = [
          "echo \"%{A1:${pkgs.dunst}/bin/dunstctl set-paused true && polybar-msg hook dunst 2:} %{A}\""
          "echo \"%{A1:${pkgs.dunst}/bin/dunstctl set-paused false && polybar-msg hook dunst 1:} %{A}\""
        ];
      };
    };
  };
}
