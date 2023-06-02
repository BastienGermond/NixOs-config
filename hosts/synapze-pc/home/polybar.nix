{ config, pkgs, ... }:

let
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
in
{
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
      for m in $(${pkgs.xorg.xrandr}/bin/xrandr --query | \
                 ${pkgs.gnugrep}/bin/grep " connected" | \
                 ${pkgs.coreutils}/bin/cut -d" " -f1); do
        MONITOR=$m polybar --reload default &
      done
    '';
    settings = {
      "module/wireguard" = {
        type = "custom/script";
        exec = "${polybar-wg} ";
        tail = false;
        interval = 5;
      };
      "module/spotibar-previous-track" = {
        type = "custom/script";
        exec = "echo ";
        click-left = "${pkgs.spotibar}/bin/spotibar --previous-track";
        exec-if = "[ $(${pkgs.spotibar}/bin/spotibar --is-live) = \"True\" ]";
        format-underline = "#1db954";
        format-padding = 1;
      };
      "module/spotibar-currently-playing" = {
        type = "custom/script";
        exec = "${pkgs.spotibar}/bin/spotibar --get-currently-playing";
        click-right = "${pkgs.spotibar}/bin/spotibar --toggle-playback";
        exec-if = "[ $(${pkgs.spotibar}/bin/spotibar --is-live) = \"True\" ]";
        format-underline = "#1db954";
        format-padding = 0;
      };
      "module/spotibar-next-track" = {
        type = "custom/script";
        exec = "echo ";
        click-left = "${pkgs.spotibar}/bin/spotibar --next-track";
        exec-if = "[ $(${pkgs.spotibar}/bin/spotibar --is-live) = \"True\" ]";
        format-underline = "#1db954";
        format-padding = 1;
      };
    };
  };
}
