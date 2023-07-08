{ config, pkgs, ... }:

let
  nextcloudRedisPort = 6380;
in
{
  services.redis.servers.nextcloud = {
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

  services.postgresqlCipheredBackup = {
    databases = [ "nextcloud" ];
  };

  systemd.services.nextcloud-cron.after = [ "postgresql.service" ];
  systemd.services.nextcloud-cron.wants = [ "postgresql.service" ];

  systemd.services.nextcloud-setup.after = [ "postgresql.service" ];
  systemd.services.nextcloud-setup.wants = [ "postgresql.service" ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
    hostName = "cloud.germond.org";
    home = "/datastore/nextcloud";
    https = true;

    enableBrokenCiphersForSSE = false;

    maxUploadSize = "10G";

    extraApps = {
      oidc_login = pkgs.fetchNextcloudApp {
        sha256 = "sha256-lQaoKjPTh1RMXk2OE+ULRYKw70OCCFq1jKcUQ+c6XkA=";
        url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v2.5.1/oidc_login.tar.gz";
      };

      breezedark = pkgs.fetchNextcloudApp {
        sha256 = "sha256-1/woeAdmvICUulv+mUdyeB92b64wKSxnw4XoP6hkiN0=";
        url = "https://github.com/mwalbeck/nextcloud-breeze-dark/releases/download/v26.0.0/breezedark.tar.gz";
      };

      # FIXME: Not yet ready (https://github.com/icewind1991/files_markdown/issues/200)
      # files_markdown = pkgs.fetchNextcloudApp rec {
      #   sha256 = "sha256-vv/PVDlQOm7Rjhzv8KXxkGpEnyidrV2nsl+Z2fdAFLY=";
      #   url = "https://github.com/icewind1991/files_markdown/releases/download/v2.3.6/files_markdown.tar.gz";
      # };

      # files_texteditor = pkgs.fetchNextcloudApp {
      #   sha256 = "sha256-Wvd5FhB0kAokaezqBK2QpfIDZgCVjmt1QO2SwSMJs2Y=";
      #   url = "https://github.com/nextcloud/files_texteditor/releases/download/v2.15.0/files_texteditor.tar.gz";
      # };

      # FIXME: Not yet ready (https://github.com/PaulLereverend/NextcloudDuplicateFinder/issues/105)
      # duplicatefinder = pkgs.fetchNextcloudApp rec {
      #   sha256 = "sha256-ZJLwKsRpS0BZU6+HtLbxkQBDM15RL+F0mwynHKujy60=";
      #   url = "https://github.com/PaulLereverend/NextcloudDuplicateFinder/releases/download/0.0.15/duplicatefinder.tar.gz";
      # };

      notes = pkgs.fetchNextcloudApp {
        sha256 = "sha256-53rKTAlsKUAonGzxgAgcMjuFX3Obpx3aKKEKlT89E0g=";
        url = "https://github.com/nextcloud/notes/releases/download/v4.8.0-beta.2/notes.tar.gz";
      };

      announcementcenter = pkgs.fetchNextcloudApp {
        sha256 = "sha256-mDQfzf3YLcCrlYYG8o9WfmBXYePSJS1W3W3MuL7SbLI=";
        url = "https://github.com/nextcloud-releases/announcementcenter/releases/download/v6.6.1/announcementcenter-v6.6.1.tar.gz";
      };

      calendar = pkgs.fetchNextcloudApp {
        sha256 = "sha256-3qDrDs5XRkpNWR12MzZg6Th5uWUe7pD9El5p6iCkm1c=";
        url = "https://github.com/nextcloud-releases/calendar/releases/download/v4.4.1/calendar-v4.4.1.tar.gz";
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
      oidc_login_client_id = "nextcloud";
      oidc_login_provider_url = "https://newsso.germond.org/realms/germond/";
      oidc_login_auto_redirect = true;
      oidc_login_hide_password_form = true;
      oidc_login_scope = "openid email profile nextcloud";
      oidc_login_end_session_redirect = true;
      oidc_login_logout_url = "https://cloud.germond.org";
      oidc_login_disable_registration = false;
      oidc_login_redir_fallback = true;
      oidc_login_attributes = {
        id = "preferred_username";
        name = "name";
        mail = "email";
        # groups = "groups";
        quota = "quota";
      };
      oidc_create_groups = false;
      oidc_login_button_text = "Germond SSO";

      # Cache
      memcache.local = "\\OC\\Memcache\\APCu";
      memcache.locking = "\\OC\\Memcache\\Redis";

      redis = {
        host = "localhost";
        port = nextcloudRedisPort;
        dbindex = 0;
        timeout = 1.5;
      };
    };
  };
}
