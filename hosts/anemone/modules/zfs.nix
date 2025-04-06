{...}: {
  fileSystems."/datastore/nextcloud" = {
    device = "datastore/nextcloud";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/postgres" = {
    device = "datastore/postgres";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/minio" = {
    device = "datastore/minio";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/paperless" = {
    device = "datastore/paperless";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/matrix-synapse" = {
    device = "datastore/matrix-synapse";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/gitea" = {
    device = "datastore/gitea";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/forgejo" = {
    device = "datastore/forgejo";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/deluge" = {
    device = "datastore/deluge";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/bookstack" = {
    device = "datastore/bookstack";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/peertube" = {
    device = "datastore/peertube";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/immich" = {
    device = "datastore/immich";
    fsType = "zfs";
    options = ["zfsutil"];
  };

  fileSystems."/datastore/komga" = {
    device = "datastore/komga";
    fsType = "zfs";
    options = ["zfsutil"];
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
