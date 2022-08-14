{ config, pkgs, ... }:

{
  config = {
    sops.defaultSopsFile = ../secrets/secrets.yml;
    sops.secrets.grafanaSecretKey = {
      owner = config.users.users.grafana.name;
    };
    sops.secrets.grafanaOAuthClientID = {
      owner = config.users.users.grafana.name;
    };
    sops.secrets.grafanaOAuthSecret = {
      owner = config.users.users.grafana.name;
    };
  };
}
