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
