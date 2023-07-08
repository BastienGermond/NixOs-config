# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  infra,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.tmp.cleanOnBoot = true;

  # Required for postgres authentication.
  services.oidentd.enable = true;

  services.postgresql.package = pkgs.postgresql_14;
  services.postgresql.authentication = lib.mkOverride 10 ''
    local all all ident
    host keycloak keycloak 127.0.0.1/32 scram-sha-256
    host all all 127.0.0.1/32 ident
  '';

  # Base configuration for postgresql ciphered backup
  services.postgresqlCipheredBackup = {
    enable = true;
    compression = "gzip";
    gpgKeyID = "4B4BF1563B72C6170FD2B835E1B6C1650DF13CAF";
    location = "/srv/backup";
    s3 = {
      enable = true;
      bucket = "coral-pg-backup";
      configFile = config.sops.secrets.PostgresBackupS3ConfigFile.path;
    };
  };

  programs.zsh.enable = true;

  environment.variables.XDG_CONFIG_HOME = "$HOME/.config";
  environment.variables.EDITOR = "vim";

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

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking = let
    anemone = infra.hosts.anemone;
  in {
    hostName = "coral";
    nameservers = ["1.1.1.1" "8.8.8.8"];
    useDHCP = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [22 2222];
      extraCommands = ''
      '';

      extraStopCommands = ''
      '';
    };

    # Gitea forward ssh port
    nat = {
      enable = true;
      externalInterface = "enp1s0";
      enableIPv6 = true;
      forwardPorts = [
      ];
    };

    enableIPv6 = true;

    interfaces.enp1s0.ipv6.addresses = [
      {
        address = "2a01:4f9:c010:b3c0::";
        prefixLength = 64;
      }
    ];

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };

    hosts = {
      "127.0.0.1" = ["germond.org" "mx.germond.org"];
    };
  };

  systemd.services.NetworkManager-wait-online.enable = false;

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

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
