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

    systemd.services.nextcloud-setup.wants = [
      "postgresql.service"
    ];

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud24;
      hostName = "cloud.germond.org";
      home = "/datastore/nextcloud";
      https = true;

      maxUploadSize = "10G";

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

        # files_texteditor = pkgs.fetchNextcloudApp rec {
        #   name = "files_texteditor";
        #   sha256 = "sha256-QiOHQ+WbB0ssI0eVk5lpOfnRzBCiBHvADy5rQiVStTc=";
        #   url = "https://github.com/nextcloud-releases/files_texteditor/releases/download/v${version}/files_texteditor.tar.gz";
        #   version = "2.14.0";
        # };

        duplicatefinder = pkgs.fetchNextcloudApp rec {
          name = "duplicatefinder";
          sha256 = "sha256-3LEFbkRU7QpCCx4ziDyiQZVFBjIHwRzAO17FSGcLYBM=";
          url = "https://github.com/PaulLereverend/NextcloudDuplicateFinder/releases/download/${version}/duplicatefinder.tar.gz";
          version = "0.0.15";
        };

        notes = pkgs.fetchNextcloudApp rec {
          name = "notes";
          sha256 = "sha256-6XwrMVX0ioqqWg4mhaxy07M3RLHmQ2DsMxBtRM95Olc=";
          url = "https://github.com/nextcloud/notes/releases/download/v${version}/notes.tar.gz";
          version = "4.5.0";
        };

        announcementcenter = pkgs.fetchNextcloudApp rec {
          name = "announcementcenter";
          sha256 = "sha256-PZ7lEBW7h6/A+VpyQ4/JLRmMaFZptyDCuIy7iC2+o1Y=";
          url = "https://github.com/nextcloud-releases/announcementcenter/releases/download/v${version}/announcementcenter-v${version}.tar.gz";
          version = "6.3.1";
        };
      };

      phpOptions = {
        short_open_tag = "Off";
        expose_php = "Off";
        error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
        display_errors = "stderr";
        "opcache.enable_cli" = "1";
        "opcache.interned_strings_buffer" = "8";
        "opcache.max_accelerated_files" = "10000";
        "opcache.memory_consumption" = "128";
        "opcache.revalidate_freq" = "1";
        "opcache.fast_shutdown" = "1";
        "openssl.cafile" = "/etc/ssl/certs/ca-certificates.crt";
        output_buffering = "on";
        catch_workers_output = "yes";
      };

      poolSettings = {
        "pm" = "dynamic";
        "pm.max_children" = "400"; # "32";
        "pm.start_servers" = "10"; # "2";
        "pm.min_spare_servers" = "10"; # "2";
        "pm.max_spare_servers" = "25"; # "4";
        "pm.max_requests" = "500";
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

        lost_password_link = "disabled";

        # OIDC Login configuration
        oidc_login_provider_url = "https://sso.germond.org/application/o/nextcloud/";
        oidc_login_auto_redirect = false;
        oidc_login_hide_password_form = true;
        oidc_login_scope = "openid email profile nextcloud";
        oidc_login_end_session_redirect = false;
        oidc_login_disable_registration = false;
        oidc_login_attributes = {
          id = "preferred_username";
          name = "name";
          mail = "email";
          groups = "groups";
          quota = "quota";
        };
        oidc_create_groups = true;
        oidc_login_button_text = "Germond SSO";

        # Cache
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
