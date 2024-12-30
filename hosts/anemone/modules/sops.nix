{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.defaultSopsFile = ../secrets/secrets.yml;

  sops.secrets = lib.mkMerge [
    {
      minioCreds = {
        owner = "minio";
        restartUnits = ["minio.service"];
      };

      geoipLicenseKey = {};

      ImmichOIDCSecret = {
        owner = "immich";
      };
    }

    (lib.mkIf config.services.nextcloud.enable {
      nextcloudAdminPass = {
        owner = config.users.users.nextcloud.name;
        restartUnits = ["nextcloud-setup.service"];
      };
      nextcloudSupwaSecrets = {
        owner = config.users.users.nextcloud.name;
        restartUnits = ["nextcloud-setup.service"];
      };
    })

    (lib.mkIf config.services.postgresqlCipheredBackup.enable {
      PostgresBackupS3ConfigFile = {
        owner = "postgres";
      };
    })

    (lib.mkIf config.services.matrix-synapse.enable {
      SynapseRegistrationSharedSecret = {
        owner = "matrix-synapse";
      };
    })

    (lib.mkIf config.services.deluge.enable {
      DelugeAuth = {
        owner = config.services.deluge.user;
      };
    })

    (lib.mkIf config.services.bookstack.enable {
      BookstackAppKey = {
        owner = config.services.bookstack.user;
      };
      BookstackOIDCSecret = {
        owner = config.services.bookstack.user;
      };
      BookstackS3Secret = {
        owner = config.services.bookstack.user;
      };
    })

    (lib.mkIf config.services.peertube.enable {
      PeertubeSecret = {
        owner = config.services.peertube.user;
      };
    })
  ];
}
