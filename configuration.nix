# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./system/fs.nix
      ./system/hardware.nix
      ./system/services.nix
      ./system/programs.nix
      ./system/packages.nix
      ./users/users.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.variables.XDG_CONFIG_HOME = "$HOME/.config";
  environment.variables.TERM = "alacritty";
  environment.variables.EDITOR = "vim";

  environment.interactiveShellInit = ''
    alias gs='git status'
  '';

  environment.pathsToLink = [ "/share/zsh" ];

  virtualisation.docker.enable = true;

  networking.hostName = "synapze-pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  networking.interfaces.wlp0s20f3.useDHCP = true;

  networking.networkmanager.enable = true;
  
  networking.nat.internalInterfaces = [ "wg0" ];
 
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.10.3/32" ];
      listenPort = 51821;
      privateKeyFile = "/home/synapze/.wg/wg0.pkey";

      peers = [
        {
          publicKey = "IOXJd4A9NO9JMcRcQRl5QYL8WW0s13+PMnyZVbbr728=";
          allowedIPs = [ "10.100.10.0/24" ];
          endpoint = "135.181.36.15:51821";
          persistentKeepalive = 25;
        }
      ];
    };
  };


  documentation = {
    man.enable = true;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

