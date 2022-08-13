{ config, pkgs, ... }:

{
  config = {
    sops.defaultSopsFile = ../secrets/secrets.yml;
    sops.secrets.grafanaSecretKey = { };
  };
}
