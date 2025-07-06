{pkgs, ...}: {
  services.autorandr = {
    enable = true;
    matchEdid = true;
    hooks.postswitch = {
      "notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
      "restart-polybar" = "systemctl restart --user polybar";
    };
    profiles = {
      "default" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "2256x1504";
            rate = "60.00";
            position = "0x1080";
          };
        };
      };
      "home" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
          DP-10 = "00ffffffffffff0010aca4a053414c341c19010380351e78ee7e75a755529c270f5054a54b00714f8180a9c0a940d1c0010101010101023a801871382d40582c45000f282100001e000000ff003954473436353738344c41530a000000fc0044454c4c205532343134480a20000000fd00384c1e5311000a202020202020016a02031ff14c9005040302071601141f12132309070765030c00100083010000023a801871382d40582c45000f282100001e011d8018711c1620582c25000f282100009e011d007251d01e206e2855000f282100001e8c0ad08a20e02d10103e96000f282100001800000000000000000000000000000000000000000000000037";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "2256x1504";
            rate = "60.00";
            position = "0x1080";
          };
          DP-10 = {
            enable = true;
            primary = true;
            mode = "1920x1080";
            rate = "60.00";
            position = "0x0";
          };
        };
      };
    };
  };

  services.pipewire.enable = false;

  services.udev = {
    extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374a", \
      MODE:="0666", \
      SYMLINK+="stlinkv2-1_%n"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", \
          MODE:="0666", \
          SYMLINK+="stlinkv2-1_%n"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", \
          MODE:="0666", \
          SYMLINK+="stlinkv2-1_%n"
    '';
    packages = [
      pkgs.yubikey-personalization
      pkgs.platformio
      pkgs.openocd
      pkgs.android-udev-rules
      pkgs.qmk-udev-rules
    ];
  };

  services.thermald.enable = true;

  services.teamviewer.enable = true;

  services.printing.enable = true;
  services.printing.drivers = with pkgs; [hplipWithPlugin carps-cups gutenprintBin cnijfilter2];
}
