# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./services.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.tmp.cleanOnBoot = true;

  my = {
    hostname = "coral";
    mainUser = "synapze";
    color = "red";
    isAServer = true;
    enableDocker = false;
    enableInfraVpn = true;
    networking = {
      enableFirewall = true;
      extraAllowedTCPPorts = [22 2222 5201];
    };
  };

  # It's a VPS and doesn't need fwupd and light.
  services.fwupd.enable = lib.mkForce false;
  programs.light.enable = lib.mkForce false;

  # Required for postgres authentication.
  services.oidentd.enable = true;

  services.postgresql.package = pkgs.postgresql_14;
  services.postgresql.authentication = lib.mkOverride 20 ''
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

  environment.variables.XDG_CONFIG_HOME = "$HOME/.config";

  networking = {
    useDHCP = true;

    # Gitea forward ssh port
    nat = {
      enable = true;
      externalInterface = "enp1s0";
      enableIPv6 = true;
      forwardPorts = [
      ];
    };

    interfaces.enp1s0.ipv6.addresses = [
      {
        address = "2a01:4f9:c010:b3c0::";
        prefixLength = 64;
      }
      {
        address = "2a01:4f9:c010:b3c0::1";
        prefixLength = 128;
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

  system.stateVersion = "21.11";
}
