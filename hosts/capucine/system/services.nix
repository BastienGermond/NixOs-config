{
  config,
  pkgs,
  ...
}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["modesetting"];

  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      i3lock
      polybarFull
      at-spi2-core
    ];
  };

  services.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
  };

  # Configure keymap in X11
  # FIXME: Might be redundant with modules/xorg.nix
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  services.displayManager.autoLogin.enable = true;

  # Required to use smart card mode (CCID)
  services.pcscd.enable = true;

  services.fwupd.enable = true;

  services.pipewire.enable = false;

  services.actkbd = {
    enable = true;
    bindings = [
      # Brightness keys
      {
        keys = [224];
        events = ["key"];
        command = "/run/current-system/sw/bin/light -U 10";
      }
      {
        keys = [225];
        events = ["key"];
        command = "/run/current-system/sw/bin/light -A 10";
      }
    ];
  };

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.thermald.enable = true;

  services.teamviewer.enable = true;

  # Enable for Nautilus https://nixos.wiki/wiki/Nautilus
  services.gvfs.enable = true;

  services.printing.enable = true;

  services.davfs2.enable = true;

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
