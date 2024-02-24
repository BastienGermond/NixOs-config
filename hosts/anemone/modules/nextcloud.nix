{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = ["nextcloud"];
  };

  services.postgresqlCipheredBackup = {
    databases = ["nextcloud"];
  };

  systemd.services.nextcloud-cron.after = ["postgresql.service"];
  systemd.services.nextcloud-cron.wants = ["postgresql.service"];

  systemd.services.nextcloud-setup.after = ["postgresql.service"];
  systemd.services.nextcloud-setup.wants = ["postgresql.service"];
  systemd.services.postgresql.wantedBy = ["nextcloud-setup.service"];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28;
    hostName = "cloud.germond.org";
    home = "/datastore/nextcloud";
    https = true;

    configureRedis = true;

    maxUploadSize = "10G";

    extraApps = {
      oidc_login = pkgs.fetchNextcloudApp {
        sha256 = "sha256-cN5azlThKPKRVip14yfUNR85of5z+N6NVI7sg6pSGQI=";
        url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.0.2/oidc_login.tar.gz";
        license = "agpl3Only";
      };

      # FIXME: Not yet ready for NC28: https://github.com/mwalbeck/nextcloud-breeze-dark/issues/339
      # breezedark = pkgs.fetchNextcloudApp {
      #   sha256 = "sha256-ad+OGE8VcZHYG24S4y3283tSxtxG0EskExwh3174iRI=";
      #   url = "https://github.com/mwalbeck/nextcloud-breeze-dark/releases/download/v27.0.0/breezedark.tar.gz";
      #   license = "agpl3Only";
      # };

      # FIXME: Not yet ready (https://github.com/icewind1991/files_markdown/issues/200)
      # files_markdown = pkgs.fetchNextcloudApp rec {
      #   sha256 = "sha256-vv/PVDlQOm7Rjhzv8KXxkGpEnyidrV2nsl+Z2fdAFLY=";
      #   url = "https://github.com/icewind1991/files_markdown/releases/download/v2.3.6/files_markdown.tar.gz";
      # };

      # files_texteditor = pkgs.fetchNextcloudApp {
      #   sha256 = "sha256-Wvd5FhB0kAokaezqBK2QpfIDZgCVjmt1QO2SwSMJs2Y=";
      #   url = "https://github.com/nextcloud/files_texteditor/releases/download/v2.15.0/files_texteditor.tar.gz";
      # };

      duplicatefinder = pkgs.fetchNextcloudApp rec {
        sha256 = "sha256-sY9tZCS9WVwXzlp5+9JzoF1bn2vMMhB1MrewZKS1cQM=";
        url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.1.8/duplicatefinder-v1.1.8.tar.gz";
        license = "agpl3Plus";
      };

      notes = pkgs.fetchNextcloudApp {
        sha256 = "sha256-7GkTGyGTvtDbZsq/zOdbBE7xh6DZO183W6I5XX1ekbw=";
        url = "https://github.com/nextcloud/notes/releases/download/v4.8.1/notes.tar.gz";
        license = "agpl3Only";
      };

      announcementcenter = pkgs.fetchNextcloudApp {
        sha256 = "sha256-GvX0MG2Ei00zaAqfKckkFO5esimmmBQsRVsV3oqAuII=";
        url = "https://github.com/nextcloud-releases/announcementcenter/releases/download/v6.7.0/announcementcenter-v6.7.0.tar.gz";
        license = "agpl3Only";
      };

      calendar = pkgs.fetchNextcloudApp {
        sha256 = "sha256-WsNc55+4fJyaOMAIseU6AB6TxC4jxwqDwBIQgxkzsaI=";
        url = "https://github.com/nextcloud-releases/calendar/releases/download/v4.6.5/calendar-v4.6.5.tar.gz";
        license = "agpl3Only";
      };

      user_usage_report = pkgs.fetchNextcloudApp {
        sha256 = "sha256-hBw+//hLJoiqBscuuUz/FApPXryFj8++gRpvk5ui22I=";
        url = "https://github.com/nextcloud-releases/user_usage_report/releases/download/v1.12.0/user_usage_report-v1.12.0.tar.gz";
        license = "agpl3Plus";
      };
    };

    phpOptions = {
      short_open_tag = "Off";
      expose_php = "Off";
      error_reporting = "E_ALL & ~E_DEPRECATED & ~E_STRICT";
      display_errors = "stderr";
      "opcache.enable_cli" = "1";
      "opcache.interned_strings_buffer" = "16";
      "opcache.max_accelerated_files" = "10000";
      "opcache.memory_consumption" = "128";
      "opcache.revalidate_freq" = "1";
      "opcache.fast_shutdown" = "1";
      "openssl.cafile" = "/etc/ssl/certs/ca-certificates.crt";
      output_buffering = "false";
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
      apcu = true;
    };

    config = {
      dbuser = "nextcloud";
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbhost = "localhost:5432";

      adminpassFile = config.sops.secrets.nextcloudAdminPass.path;
    };

    secretFile = config.sops.secrets.nextcloudSupwaSecrets.path;

    settings = {
      allow_user_to_change_display_name = false;
      default_phone_region = "FR";

      # Maintenance
      # Run background jobs during the morning/night
      maintenance_window_start = 1; # 01:00am UTC and 05:00am UTC

      # Proxy stuff
      overwriteprotocol = "https";
      "overwrite.cli.url" = "https://cloud.germond.org";
      trusted_proxies = ["10.100.10.1"];

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
    };
  };
}
