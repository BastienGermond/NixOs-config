{ config, pkgs, ... }:

{
  config = {
    sops.defaultSopsFile = ../secrets/secrets.yml;
    sops.secrets.authentik = { };
    sops.secrets.geoipLicenseKey = { };
  };
}
