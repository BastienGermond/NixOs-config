# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.cleanTmpDir = true;

  services.gatus = {
    enable = true;
    config = {
      web = {
        address = "127.0.0.1";
        port = 8040;
      };
      storage = {
        type = "postgres";
        path = "postgres://gatus@127.0.0.1:5432/gatus?sslmode=disable";
      };
      ui = {
        title = "Germond's Infrastructure Monitoring";
        description = "Monitoring of my infrastructure, mostly under domain germond.org.";
      };
      endpoints = [
        {
          name = "Authentik";
          group = "Authentication";
          url = "https://sso.germond.org";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Nextcloud";
          group = "Cloud";
          url = "https://cloud.germond.org";
          conditions = [
            "[STATUS] == 200"
          ];
        }
        {
          name = "Grafanouille";
          group = "Monitoring";
          url = "https://grafana.germond.org";
          conditions = [
            "[STATUS] == 200"
          ];
        }
      ];
    };
  };

  # Required for postgres authentication.
  services.oidentd.enable = true;

  services.postgresql.package = pkgs.postgresql_14;
  services.postgresql.authentication = lib.mkOverride 10 ''
    local all all ident
    host all all 127.0.0.1/32 ident
  '';

  # Gatus
  services.postgresql.ensureDatabases = [ "gatus" ];
  services.postgresql.ensureUsers = [
    {
      name = "gatus";
      ensurePermissions = {
        "DATABASE \"gatus\"" = "ALL PRIVILEGES";
      };
    }
  ];

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

  environment.pathsToLink = [ "/share/zsh" ];

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking = {
    hostName = "coral";
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
    useDHCP = true;

    firewall.enable = false;

    enableIPv6 = true;

    interfaces.enp1s0.ipv6.addresses = [{
      address = "2a01:4f9:c010:b3c0::";
      prefixLength = 64;
    }];

    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
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

