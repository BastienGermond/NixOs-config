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

    services.postgresqlBackup = {
      enable = true;
      databases = [ "nextcloud" ];
    };

    systemd.services.nextcloud-cron.after = [ "postgresql.service" ];
    systemd.services.nextcloud-cron.wants = [ "postgresql.service" ];

    systemd.services.nextcloud-setup.after = [ "postgresql.service" ];
    systemd.services.nextcloud-setup.wants = [ "postgresql.service" ];

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud24;
      hostName = "cloud.germond.org";
      home = "/datastore/nextcloud";
      https = true;

      maxUploadSize = "10G";

      extraApps = {
        oidc_login = pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-zku8TEqv3FUK45Xc4/cLAQtUhn0odW8P014HOIgOCuA=";
          url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v2.3.2/oidc_login.tar.gz";
        };

        breezedark = pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-2tBm45gh5VRKh+w5YcBGyuNB7EGIdBh67jSLfrq+4R4=";
          url = "https://github.com/mwalbeck/nextcloud-breeze-dark/releases/download/v24.0.2/breezedark.tar.gz";
        };

        files_markdown = pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-vv/PVDlQOm7Rjhzv8KXxkGpEnyidrV2nsl+Z2fdAFLY=";
          url = "https://github.com/icewind1991/files_markdown/releases/download/v2.3.6/files_markdown.tar.gz";
        };

        # files_texteditor = pkgs.fetchNextcloudApp rec {
        #   name = "files_texteditor";
        #   sha256 = "sha256-QiOHQ+WbB0ssI0eVk5lpOfnRzBCiBHvADy5rQiVStTc=";
        #   url = "https://github.com/nextcloud-releases/files_texteditor/releases/download/v${version}/files_texteditor.tar.gz";
        #   version = "2.14.0";
        # };

        duplicatefinder = pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-ZJLwKsRpS0BZU6+HtLbxkQBDM15RL+F0mwynHKujy60=";
          url = "https://github.com/PaulLereverend/NextcloudDuplicateFinder/releases/download/0.0.15/duplicatefinder.tar.gz";
        };

        notes = pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-VmnNdP9oia2zCfjHbVvRKeKNL5PoOAk+ZuLV4GScxm4=";
          url = "https://github.com/nextcloud/notes/releases/download/v4.5.0/notes.tar.gz";
        };

        announcementcenter = pkgs.fetchNextcloudApp rec {
          sha256 = "sha256-1w/pY+4HKlugmSN9vyUryeepIaOemjW1W5zwEIgTLCI=";
          url = "https://github.com/nextcloud-releases/announcementcenter/releases/download/v6.3.1/announcementcenter-v6.3.1.tar.gz";
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
