{ config, pkgs, ... }:

{
  services.minio = {
    enable = true;
    region = "eu-west-3"; # Paris
    dataDir = [ "/datastore/minio/data" ];
    configDir = "/datastore/minio/config";
    listenAddress = ":9030";
    consoleAddress = ":9031";
    rootCredentialsFile = config.sops.secrets.minioCreds.path;
  };
}
