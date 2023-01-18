{ config, pkgs, lib, ... }:

{
  sops.defaultSopsFile = ../secrets/secrets.yml;

  sops.secrets = lib.mkMerge [
    {
      # ldapRootPW = {
      #   owner = config.services.openldap.user;
      # };
      nginxTrapCertKey = {
        owner = config.users.users.nginx.name;
      };
      alertmanagerEnv = { };
      nsdGermondOrgTsigSecret = { };
      acmeGermondOrgCredsEnv = { };
      bindDnsKey = {
        owner = config.users.users."named".name;
      };
    }

    (lib.mkIf config.services.grafana.enable {
      grafanaSecretKey = {
        owner = config.users.users.grafana.name;
        restartUnits = [ "grafana.service" ];
      };
      grafanaOAuthClientID = {
        owner = config.users.users.grafana.name;
        restartUnits = [ "grafana.service" ];
      };
      grafanaOAuthSecret = {
        owner = config.users.users.grafana.name;
        restartUnits = [ "grafana.service" ];
      };
    })

    (lib.mkIf config.services.transfer_sh.enable {
      transferShEnv = {
        owner = config.services.transfer_sh.user;
      };
    })

    (lib.mkIf config.services.hedgedoc.enable {
      hedgedocEnv = {
        owner = "hedgedoc";
      };
    })
  ];
}
