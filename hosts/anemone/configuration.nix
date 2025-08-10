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
    ./services.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    tmp.cleanOnBoot = true;
    supportedFilesystems = ["zfs"];
  };

  my = {
    hostname = "anemone";
    mainUser = "synapze";
    color = "yellow";
    isAServer = true;
    enableDocker = true;
    enableInfraVpn = true;
    networking = {
      enableFirewall = true;
      extraAllowedTCPPorts = [22 2222 5201];
    };
  };

  services.fwupd.enable = true;

  programs.zsh.enable = true;

  services.geoipupdate.settings = {
    enable = false;
    AccountID = 753286;
    LicenseKey = config.sops.secrets.geoipLicenseKey.path;
    EditionIDs = ["GeoLite2-City"];
  };

  services.postgresql = {
    package = pkgs.postgresql_14;
    enable = true;
    authentication = lib.mkOverride 20 ''
      local all all ident
      host all all 127.0.0.1/32 ident
    '';
  };

  services.postgresqlBackup.location = "/datastore/postgres";

  services.postgresqlCipheredBackup = {
    enable = true;
    compression = "gzip";
    gpgKeyID = "4B4BF1563B72C6170FD2B835E1B6C1650DF13CAF";
    location = "/srv/backup";
    s3 = {
      enable = true;
      bucket = "anemone-pg-backup";
      configFile = config.sops.secrets.PostgresBackupS3ConfigFile.path;
    };
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.

  environment.etc."modprobe.d/zfs.conf".text = ''
    options zfs
  '';

  networking = {
    hostId = "aafe2a96";

    interfaces.enp8s0.useDHCP = true;
    networkmanager.enable = true;
  };

  networking.firewall = {
    logReversePathDrops = true;
    allowedTCPPorts = with infra.hosts.anemone.ports; [
      gitea
      gitea-ssh
      komga
      matrix-synapse-monitoring
      minio
      node-exporter
      paperless
      promtail
      s3
      22
      80
      8008
      5201 # iperf3
    ];
    extraCommands = ''

    '';
  };

  system.stateVersion = "21.11"; # Did you read the comment?
}
