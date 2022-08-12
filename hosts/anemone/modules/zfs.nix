{ config, pkgs, ... }:

{
  fileSystems."/datastore/nextcloud" = {
    device = "datastore/nextcloud";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/datastore/postgres" = {
    device = "datastore/postgres";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/datastore/authentik" = {
    device = "datastore/authentik";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
    trim = {
      enable = true;
      interval = "weekly";
    };
  };
}
