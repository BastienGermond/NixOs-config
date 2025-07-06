# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./fs.nix
    ./system
    ./sops.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  environment.variables.XDG_CONFIG_HOME = "$HOME/.config";
  environment.variables.TERM = "alacritty";
  environment.variables.EDITOR = "hx";

  environment.extraInit = ''
    # these are the defaults, but some applications are buggy so we set them
    # here anyway
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_CACHE_HOME=$HOME/.cache
  '';

  environment.interactiveShellInit = ''
    alias gs='git status'
  '';

  environment.pathsToLink = ["/share/zsh"];

  virtualisation.docker.enable = true;

  networking.hostName = "capucine"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking.nameservers = ["1.1.1.1" "8.8.8.8"];
  networking.hostId = "98af64da";

  networking.networkmanager.enable = true;

  documentation = {
    enable = true;
    info.enable = true;
    doc.enable = true;
    dev.enable = true;
    nixos.enable = true;

    man = {
      enable = true;
      generateCaches = true;
    };
  };

  # This service hang until timeout for 1min at each switch, disabling it temporarily until a
  # better solution is found. (https://github.com/NixOS/nixpkgs/issues/180175)
  systemd.services.NetworkManager-wait-online.enable = false;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod.enable = true;
  i18n.inputMethod.type = "ibus";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
