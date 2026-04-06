{
  pkgs,
  lib,
  ...
}: {
  services.autorandr = {
    enable = true;
    matchEdid = true;
    ignoreLid = true;
    hooks.postswitch = {
      "notify-i3" = "${pkgs.i3}/bin/i3-msg restart";
      "restart-polybar" = "pkill -9 polybar";
    };
    profiles = {
      "default" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0009e5350a00000000141f0104a51e137803a1d5985e59932820505400000001010101010101010101010101010101333f80dc70b03c40302036002ebd1000001a000000fd00283c4c4c10010a202020202020000000fe00424f452043510a202020202020000000fe004e5631343057554d2d4e34330a00b5";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "1920x1200";
            rate = "60.00";
            position = "0x1080";
          };
        };
      };
      "home" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0009e5350a00000000141f0104a51e137803a1d5985e59932820505400000001010101010101010101010101010101333f80dc70b03c40302036002ebd1000001a000000fd00283c4c4c10010a202020202020000000fe00424f452043510a202020202020000000fe004e5631343057554d2d4e34330a00b5";
          DP-8 = "00ffffffffffff0010aca4a053414c341c19010380351e78ee7e75a755529c270f5054a54b00714f8180a9c0a940d1c0010101010101023a801871382d40582c45000f282100001e000000ff003954473436353738344c41530a000000fc0044454c4c205532343134480a20000000fd00384c1e5311000a202020202020016a02031ff14c9005040302071601141f12132309070765030c00100083010000023a801871382d40582c45000f282100001e011d8018711c1620582c25000f282100009e011d007251d01e206e2855000f282100001e8c0ad08a20e02d10103e96000f282100001800000000000000000000000000000000000000000000000037";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "1920x1200";
            rate = "60.00";
            position = "0x1080";
          };
          DP-8 = {
            enable = true;
            primary = true;
            mode = "1920x1080";
            rate = "60.00";
            position = "0x0";
          };
        };
      };
      "office" = {
        fingerprint = {
          eDP-1 = "00ffffffffffff0009e5350a00000000141f0104a51e137803a1d5985e59932820505400000001010101010101010101010101010101333f80dc70b03c40302036002ebd1000001a000000fd00283c4c4c10010a202020202020000000fe00424f452043510a202020202020000000fe004e5631343057554d2d4e34330a00b5";
          HDMI-1 = "00ffffffffffff00220eb136010101012a1f0103803c22782a9405a952449722195054a10800d1c0a9c081c0b3009500810081800101023a801871382d40582c450056502100001e000000fd00323c1e5011000a202020202020000000fc00485020563237650a2020202020000000ff0031435231343230334c4a0a202001b2020319b149101f0413121103020167030c0010000022e2006b023a801871382d40582c450056502100001e023a80d072382d40102c458056502100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000063";
        };
        config = {
          eDP-1 = {
            enable = true;
            mode = "1920x1200";
            rate = "60.00";
            position = "0x1080";
          };
          HDMI-1 = {
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

  services.libinput.touchpad.accelSpeed = lib.mkForce "0.70";

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
      pkgs.qmk-udev-rules
    ];
  };

  services.thermald.enable = true;

  services.teamviewer.enable = true;

  services.printing = {
    enable = true;
    drivers = [pkgs.hplip pkgs.hplipWithPlugin];
  };

  # Fix from https://wiki.archlinux.org/title/Lenovo_ThinkPad_T14_(AMD)_Gen_3#Suspend/Hibernate
  systemd.services.ath11k-suspend = {
    enable = true;
    wantedBy = ["sleep.target"];
    before = ["sleep.target"];
    description = "Suspend: rmmod ath11k_pci";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.kmod}/bin/rmmod ath11k_pci'';
    };
  };
  systemd.services.ath11k-resume = {
    enable = true;
    wantedBy = ["suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target"];
    after = ["suspend.target" "suspend-then-hibernate.target" "hibernate.target" "hybrid-sleep.target"];
    description = "Resume: modprobe ath11k_pci";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.kmod}/bin/modprobe ath11k_pci'';
    };
  };
}
