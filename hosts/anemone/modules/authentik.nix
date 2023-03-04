{ config, pkgs, lib, ... }:

{
  services.authentik = {
    enable = true;
    # image = "ghcr.io/goauthentik/dev-server";
    version = "2023.2.3";
    authentikServerEnvironmentFiles = [
      config.sops.secrets.authentik.path
    ];
    config = {
      mediaFolder = "/datastore/authentik/media";
      certsFolder = "/datastore/authentik/certs";
      logLevel = "debug";
    };
    postgresBackup = {
      enable = false;
    };
    GeoIP.enable = true;
  };

  services.postgresqlCipheredBackup.databases = [ config.services.authentik.dbName ];
}
