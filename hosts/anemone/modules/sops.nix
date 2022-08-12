{ config, pkgs, ... }:

{
  config = {
    sops.defaultSopsFile = ../secrets/secrets.yml;
    sops.secrets.authentik = { };
    sops.secrets.geoipLicenseKey = { };
    sops.secrets.nextcloudAdminPass = {
      owner = config.users.users.nextcloud.name;
    };
    sops.secrets.nextcloudSupwaSecrets = {
      owner = config.users.users.nextcloud.name;
    };
  };
}
