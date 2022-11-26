{ config, pkgs, lib, ... }:

{
  services.authentik = {
    enable = true;
    # image = "ghcr.io/goauthentik/dev-server";
    version = "2022.11.1";
    authentikServerEnvironmentFiles = [
      config.sops.secrets.authentik.path
    ];
    config = {
      mediaFolder = "/datastore/authentik/media";
      certsFolder = "/datastore/authentik/certs";
      logLevel = "debug";
    };
    postgresBackup = {
      enable = true;
    };
    GeoIP.enable = true;
  };
}
