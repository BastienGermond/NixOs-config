# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [
    ./fs.nix
    ./hardware-configuration.nix
    ./services.nix
    ./sops.nix
    ./system
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  boot.binfmt.emulatedSystems = [];

  my = {
    hostname = "nautilus";
    enableDocker = true;
    enableInfraVpn = true;
    networking = {
      enableFirewall = true;
      wirelessInterfaces = ["wlp192s0"];
    };
    autorandr = {
      enable = true;
      default = {
        fingerprint = "00ffffffffffff0009e5ca0b000000002f200104a51c137803de50a3544c99260f505400000001010101010101010101010101010101115cd01881e02d50302036001dbe1000001aa749d01881e02d50302036001dbe1000001a000000fe00424f452043510a202020202020000000fe004e4531333546424d2d4e34310a0073";
        mode = "2256x1504";
        rate = "60.00";
        dpi = 120;
      };
    };
  };

  services.xserver.dpi = 120;

  environment.variables.XDG_CONFIG_HOME = "$HOME/.config";

  environment.extraInit = ''
    # these are the defaults, but some applications are buggy so we set them here anyway
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_CACHE_HOME=$HOME/.cache
  '';

  networking.hostId = "8425e349";

  system.stateVersion = "21.05";
}
