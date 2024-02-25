{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.defaultSopsFile = ../secrets/secrets.yml;

  sops.secrets = lib.mkMerge [
    {
      # ldapRootPW = {
      #   owner = config.services.openldap.user;
      # };
      nginxTrapCertKey = {
        owner = config.users.users.nginx.name;
      };
      alertmanagerEnv = {};
      nsdGermondOrgTsigSecret = {};
      acmeGermondOrgCredsEnv = {};
      bindDnsKey = {
        owner = config.users.users."named".name;
      };
    }

    (lib.mkIf config.services.grafana.enable {
      grafanaSecretKey = {
        owner = config.users.users.grafana.name;
        restartUnits = ["grafana.service"];
      };
      grafanaOAuthClientID = {
        owner = config.users.users.grafana.name;
        restartUnits = ["grafana.service"];
      };
      grafanaOAuthSecret = {
        owner = config.users.users.grafana.name;
        restartUnits = ["grafana.service"];
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
        restartUnits = ["hedgedoc.service"];
      };
    })

    (lib.mkIf config.services.postgresqlCipheredBackup.enable {
      PostgresBackupS3ConfigFile = {
        owner = "postgres";
      };
    })

    (lib.mkIf config.services.keycloak.enable {
      keycloakPostgresPassword = {
        owner = "postgres";
      };
    })

    (lib.mkIf config.mailserver.enable {
      noReplyMailPassword = {};
      testMailPassword = {};
      abuseMailPassword = {};
    })

    (lib.mkIf config.services.prometheus.enable {
      minioBearerToken = {
        owner = "prometheus";
        restartUnits = ["prometheus.service"];
      };
    })

    (lib.mkIf config.services.vouch-proxy.enable {
      vouchProxyEnv = {
        owner = config.services.vouch-proxy.user;
        restartUnits = ["vouch-proxy.service"];
      };
    })
  ];
}
