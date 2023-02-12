{ config, pkgs, infra, ... }:

let
  ports = infra.hosts.anemone.ports;
in
{
  services.minio = {
    enable = true;
    region = "eu-west-3"; # Paris
    dataDir = [ "/datastore/minio/data" ];
    configDir = "/datastore/minio/config";
    listenAddress = ":${builtins.toString ports.s3}";
    consoleAddress = ":${builtins.toString ports.minio}";
    rootCredentialsFile = config.sops.secrets.minioCreds.path;
  };
}
