{ config, pkgs, ... }:

{
  config = {
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {
            "DATABASE \"nextcloud\"" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [ "nextcloud" ];
    };

    systemd.services.nextcloud-setup.after = [
      "postgresql.service"
    ];

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud24;
      hostName = "cloud.germond.org";
      home = "/datastore/nextcloud";
      https = true;

      extraApps = {
        oidc_login = pkgs.fetchNextcloudApp {
          name = "oidc_login";
          sha256 = "sha256-B7HLZXH0JHS8QvYsdsEqnrqQGmq92u9mwUwRxNSzhU0=";
          url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v2.3.2/oidc_login.tar.gz";
          version = "2.3.2";
        };
      };

      extraAppsEnable = true;

      config = {
        dbuser = "nextcloud";
        dbtype = "pgsql";
        dbport = 5432;
        dbname = "nextcloud";
        dbhost = "localhost";

        overwriteProtocol = "https";

        adminpassFile = config.sops.secrets.nextcloudAdminPass.path;
      };

      secretFile = config.sops.secrets.nextcloudSupwaSecrets.path;

      extraOptions = {
        allow_user_to_change_display_name = false;
        lost_password_link = false;
        oidc_login_provider_url = "https://sso.germond.org/application/o/nextcloud/";
        oidc_login_auto_redirect = true;
        oidc_login_hide_password_form = true;
        oidc_login_scope = "openid email profile nextcloud";
        oidc_login_disable_registration = false;
        oidc_login_attributes = {
          id = "preferred_username";
          name = "name";
          mail = "email";
          groups = "groups";
          quota = "quota";
        };
        oidc_create_groups = true;
      };
    };
  };
}
