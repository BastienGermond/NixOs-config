{ config, pkgs, ... }:

{
  fileSystems."/datastore/nextcloud" = {
    device = "datastore/nextcloud";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  # fileSystems."/datastore/k3s/anemone" = {
  #   device = "datastore/k3s/anemone";
  #   fsType = "zfs";
  #   options = [ "zfsutil" ];
  # };

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
