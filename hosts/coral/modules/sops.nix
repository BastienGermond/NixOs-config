{ config, pkgs, ... }:

{
  sops.defaultSopsFile = ../secrets/secrets.yml;

  sops.secrets = {
    grafanaSecretKey = {
      owner = config.users.users.grafana.name;
    };
    grafanaOAuthClientID = {
      owner = config.users.users.grafana.name;
    };
    grafanaOAuthSecret = {
      owner = config.users.users.grafana.name;
    };
    nginxTrapCertKey = {
      owner = config.users.users.nginx.name;
    };
    alertmanagerEnv = { };
  };
}
