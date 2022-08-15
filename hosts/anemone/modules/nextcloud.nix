{ config, pkgs, ... }:

let
  nextcloudRedisPort = 6380;
in
{
  config = {
    services.redis.servers.redis-nextcloud = {
      enable = true;
      port = nextcloudRedisPort;
    };

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
        oidc_login = pkgs.fetchNextcloudApp rec {
          name = "oidc_login";
          sha256 = "sha256-B7HLZXH0JHS8QvYsdsEqnrqQGmq92u9mwUwRxNSzhU0=";
          url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v${version}/oidc_login.tar.gz";
          version = "2.3.2";
        };

        breezedark = pkgs.fetchNextcloudApp rec {
          name = "breezedark";
          sha256 = "sha256-NHgeCqnOrwtLuxXWSZ4ThBRkQHZmbya5DVfYRolztG8=";
          url = "https://github.com/mwalbeck/nextcloud-breeze-dark/releases/download/v${version}/breezedark.tar.gz";
          version = "24.0.2";
        };

        files_markdown = pkgs.fetchNextcloudApp rec {
          name = "files_markdown";
          sha256 = "sha256-6vrPNKcPmJ4DuMXN8/oRMr/B/dTlJn2GGi/w4t2wimk=";
          url = "https://github.com/icewind1991/files_markdown/releases/download/v${version}/files_markdown.tar.gz";
          version = "2.3.6";
        };
      };

      extraAppsEnable = true;

      caching = {
        redis = true;
        apcu = true;
      };

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

        memcache.local = "\\OC\\Memcache\\APCu";
        memcache.locking = "\\OC\\Memcache\\Redis";

        redis = {
          host = "localhost";
          port = nextcloudRedisPort;
        };
      };
    };
  };
}
