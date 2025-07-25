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

  systemd.services.NetworkManager-wait-online.enable = false;

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  ''; # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.

  environment.etc."modprobe.d/zfs.conf".text = ''
    options zfs
  '';

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

  virtualisation.docker.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking = {
    hostName = "anemone";
    hostId = "aafe2a96";

    nameservers = ["1.1.1.1" "8.8.8.8"];
    interfaces.enp8s0.useDHCP = true;
    networkmanager.enable = true;
  };

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
