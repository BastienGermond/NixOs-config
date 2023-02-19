{ config, pkgs, lib, ... }:

{
  sops.defaultSopsFile = ../secrets/secrets.yml;

  sops.secrets = lib.mkMerge [
    ({
      authentik = { };
      geoipLicenseKey = { };
      nextcloudAdminPass = {
        owner = config.users.users.nextcloud.name;
        restartUnits = [ "nextcloud-setup.service" ];
      };
      nextcloudSupwaSecrets = {
        owner = config.users.users.nextcloud.name;
        restartUnits = [ "nextcloud-setup.service" ];
      };
      minioCreds = {
        owner = "minio";
        restartUnits = [ "minio.service" ];
      };
    })

    (lib.mkIf config.services.postgresqlCipheredBackup.enable {
      PostgresBackupS3ConfigFile = {
        owner = "postgres";
      };
    })
  ];
}
