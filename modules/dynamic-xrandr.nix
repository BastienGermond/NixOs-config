{
  config,
  lib,
  pkgs,
  ...
}: let
  dynamicXrandrScript =
    pkgs.writeShellScript "dynamic-xrandr.sh"
    # bash
    ''
      #!${pkgs.bash}/bin/bash

      XRANDR=${pkgs.xorg.xrandr}/bin/xrandr
      GAWK=${pkgs.gawk}/bin/awk
      BC=${pkgs.bc}/bin/bc

      INTERNAL="eDP-1"
      EXTERNAL=$($XRANDR | $GAWK '/ connected / && $1 != "'$INTERNAL'" { print $1; exit }')

      if [ -z "$EXTERNAL" ]; then
        # Only internal connected, set default
        $XRANDR --output "$INTERNAL" --auto --primary
        exit 0
      fi

      # Get resolutions
      INT_RES=$($XRANDR | $GAWK '/^'"$INTERNAL"' connected/ { getline; print $1 }')
      EXT_RES=$($XRANDR | $GAWK '/^'"$EXTERNAL"' connected/ { getline; print $1 }')

      INT_W=$(echo "$INT_RES" | cut -d'x' -f1)
      INT_H=$(echo "$INT_RES" | cut -d'x' -f2)
      EXT_W=$(echo "$EXT_RES" | cut -d'x' -f1)
      EXT_H=$(echo "$EXT_RES" | cut -d'x' -f2)

      # Get physical widths in mm
      INT_MM=$($XRANDR | $GAWK '/^'"$INTERNAL"' connected/ { match($0, /[0-9]+mm x [0-9]+mm/, m); split(m[0], dims, "mm x "); print dims[1] }')
      if [ -z "$INT_MM" ]; then INT_MM=1; fi

      EXT_MM=$($XRANDR | $GAWK '/^'"$EXTERNAL"' connected/ { match($0, /[0-9]+mm x [0-9]+mm/, m); split(m[0], dims, "mm x "); print dims[1] }')
      if [ -z "$EXT_MM" ]; then EXT_MM=1; fi


      # Convert mm to inches (1 inch = 25.4 mm)
      to_inches() {
        echo "scale=4; $1 / 25.4" | $BC
      }

      INT_IN=$(to_inches $INT_MM)
      EXT_IN=$(to_inches $EXT_MM)

      # Calculate DPI = resolution width / physical width in inches
      dpi() {
        echo "scale=4; $1 / $2" | $BC
      }

      INT_DPI=$(dpi $INT_W $INT_IN)
      EXT_DPI=$(dpi $EXT_W $EXT_IN)

      # Use internal DPI as target
      TARGET_DPI=$INT_DPI

      # Calculate scale factors (target / current)
      SCALE_INT=$(echo "scale=4; $TARGET_DPI / $INT_DPI" | $BC)
      SCALE_EXT=$(echo "scale=4; $TARGET_DPI / $EXT_DPI" | $BC)

      # For internal usually scale is 1 (avoid very small differences)
      SCALE_INT=$(echo "$SCALE_INT < 1.01 && $SCALE_INT > 0.99" | $BC -l | grep 1 && echo "1" || echo $SCALE_INT)

      # Calculate new height for internal position (external above internal)
      SCALED_EXT_H=$(echo "$EXT_H / $SCALE_EXT" | $BC | cut -d'.' -f1)

      # Apply layout with scales and positions
      $XRANDR \
        --output "$EXTERNAL" --mode "$EXT_RES" --scale "$SCALE_EXT"x"$SCALE_EXT" --pos 0x0 \
        --output "$INTERNAL" --mode "$INT_RES" --scale "$SCALE_INT"x"$SCALE_INT" --pos 0x$SCALED_EXT_H --primary
    '';

  inherit (lib) mkEnableOption mkIf;
in {
  options = {
    services.dynamic-xrandr = {
      enable = mkEnableOption "Dynamic xrandr";
    };
  };

  config = mkIf config.services.dynamic-xrandr.enable {
    systemd.user.services.dynamicXrandr = {
      enable = false;
      description = "Run dynamic xrandr on boot and on hotplug";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${dynamicXrandrScript}";
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = "DISPLAY=:0";
      };
      after = ["graphical.target"];
    };

    systemd.paths.dynamic-xrandr = {
      pathConfig = {
        PathChanged = "/sys/class/drm";
        Unit = "dynamicXrandr.service";
      };
      wantedBy = ["multi-user.target"];
    };
  };
}
