{
  config,
  pkgs,
  lib,
  ...
}: let
  ncCfg = config.services.nextcloud;

  borgZfsBackup =
    pkgs.writeShellScriptBin "borg-zfs-backup"
    # bash
    ''
      #!/usr/bin/env bash
      set -euo pipefail
      IFS=$'\n\t'

      : "''${DATASET:?}"
      : "''${MOUNTPOINT:=/''${DATASET}}"
      : "''${BORG_REPO:?}"
      : "''${BORG_PASSPHRASE_FILE:?}"
      : "''${DB_NAME:?}"
      : "''${DB_USER:?}"
      : "''${DB_HOST:=localhost}"
      : "''${DB_PORT:=5432}"

      RETENTION_KEEP_DAILY="''${RETENTION_KEEP_DAILY:-7}"
      RETENTION_KEEP_WEEKLY="''${RETENTION_KEEP_WEEKLY:-4}"
      RETENTION_KEEP_MONTHLY="''${RETENTION_KEEP_MONTHLY:-6}"
      COMPRESSION="''${COMPRESSION:-lz4}"
      KEEP_SNAPSHOT_ON_FAILURE="''${KEEP_SNAPSHOT_ON_FAILURE:-no}"

      BORG_BIN=${pkgs.borgbackup}/bin/borg
      ZFS_BIN=/run/current-system/sw/bin/zfs
      PG_DUMP=${pkgs.postgresql}/bin/pg_dump

      DATESTR="$(date +%Y-%m-%d_%H-%M-%S)"
      SNAPNAME="backup-''${DATESTR}"
      SNAP_REF="''${DATASET}@''${SNAPNAME}"

      SNAPSHOT_PATH="''${MOUNTPOINT}/.zfs/snapshot/''${SNAPNAME}"
      LOG="/var/log/borg-zfs-backup-''${DATESTR}.log"

      export BORG_PASSPHRASE="$(cat "''${BORG_PASSPHRASE_FILE}")"
      export BORG_REPO

      cleanup() {
        rc=$?
        [ -n "''${TMP_DB_DUMP:-}" ] && rm -f "''${TMP_DB_DUMP}"
        if [ "''${SNAP_CREATED:-no}" = "yes" ]; then
          if [ $rc -eq 0 ] || [ "''${KEEP_SNAPSHOT_ON_FAILURE}" = "yes" ]; then
            :
          else
            $ZFS_BIN destroy -r "''${SNAP_REF}" || true
          fi
        fi
        unset BORG_PASSPHRASE
        exit $rc
      }
      trap cleanup EXIT HUP INT TERM

      mkdir -p /var/log
      $ZFS_BIN snapshot "''${SNAP_REF}"
      SNAP_CREATED=yes

      TMP_DB_DUMP="$(mktemp "/tmp/pgdump.XXXXXX")"
      PGHOST="''${DB_HOST}" PGUSER="''${DB_USER}" PGPORT="''${DB_PORT}" \
        "$PG_DUMP" --format=custom --file="''${TMP_DB_DUMP}" "''${DB_NAME}"

      "$BORG_BIN" create -s \
        --compression "''${COMPRESSION}" \
        "::''${DATESTR}" \
        "''${SNAPSHOT_PATH}" \
        "''${TMP_DB_DUMP}"

      "$BORG_BIN" prune \
        --keep-daily="''${RETENTION_KEEP_DAILY}" \
        --keep-weekly="''${RETENTION_KEEP_WEEKLY}" \
        --keep-monthly="''${RETENTION_KEEP_MONTHLY}"
    '';
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
    package = pkgs.nextcloud31;
    hostName = "cloud.germond.org";
    home = "/datastore/nextcloud";
    https = true;

    configureRedis = true;

    maxUploadSize = "10G";

    extraApps = {
      oidc_login = pkgs.fetchNextcloudApp {
        sha256 = "sha256-RLYquOE83xquzv+s38bahOixQ+y4UI6OxP9HfO26faI=";
        url = "https://github.com/pulsejet/nextcloud-oidc-login/releases/download/v3.2.2/oidc_login.tar.gz";
        license = "agpl3Only";
      };

      # breezedark = pkgs.fetchNextcloudApp {
      #   sha256 = "sha256-9xMH9IcQrzzMJ5bL6RP/3CS1QGuByriCjGkJQJxQ4CU=";
      #   url = "https://github.com/mwalbeck/nextcloud-breeze-dark/releases/download/v29.0.0/breezedark.tar.gz";
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

      # FIXME: Check for release
      # duplicatefinder = pkgs.fetchNextcloudApp {
      #   sha256 = "sha256-J+P+9Ajz998ua1RRwuj1h4WOOl0WODu3uVJNGosbObI=";
      #   url = "https://github.com/eldertek/duplicatefinder/releases/download/v1.6.0/duplicatefinder-v1.6.0.tar.gz";
      #   license = "agpl3Plus";
      # };

      notes = pkgs.fetchNextcloudApp {
        sha256 = "sha256-iiNXIvq+rUbbecU646pyRpHP0EjUdQT1ybKMS2JQbwc=";
        url = "https://github.com/nextcloud-releases/notes/releases/download/v4.12.4/notes-v4.12.4.tar.gz";
        license = "agpl3Only";
      };

      announcementcenter = pkgs.fetchNextcloudApp {
        sha256 = "sha256-dH0blE+NjRLBdmGakG3TrlUqgABvqFeHYMuF0IN2aMU=";
        url = "https://github.com/nextcloud-releases/announcementcenter/releases/download/v7.2.2/announcementcenter-v7.2.2.tar.gz";
        license = "agpl3Only";
      };

      calendar = pkgs.fetchNextcloudApp {
        sha256 = "sha256-GcoHXCAsyoWyXT5/55+Eu/G1D4pZe2A8iR1wRo9S/9s=";
        url = "https://github.com/nextcloud-releases/calendar/releases/download/v5.5.9/calendar-v5.5.9.tar.gz";
        license = "agpl3Only";
      };

      user_usage_report = pkgs.fetchNextcloudApp {
        sha256 = "sha256-itWaJUHnBZmsBrL4O0fps/DgSm7MEt0JeIrNM1LlRUk=";
        url = "https://github.com/nextcloud-releases/user_usage_report/releases/download/v2.0.0/user_usage_report-v2.0.0.tar.gz";
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

  # Backups

  environment.systemPackages = with pkgs; [borgbackup];

  systemd.services.borg-zfs-backup = {
    description = "Borg ZFS backup (oneshot)";
    wants = ["network-online.target"];
    after = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${borgZfsBackup}/bin/borg-zfs-backup";
      User = "root";
      Environment = [
        "DATASET=datastore/nextcloud"
        "BORG_REPO=/datastore/borg"
        "BORG_PASSPHRASE_FILE=${config.sops.secrets.BorgDatastorePassphrase.path}"

        "DB_NAME=${ncCfg.config.dbname}"
        "DB_USER=${ncCfg.config.dbuser}"
        "DB_HOST=localhost"
        "DB_PORT=5432"
      ];
    };
  };

  systemd.timers.borg-zfs-backup = {
    wantedBy = ["timers.target"];
    timerConfig.OnCalendar = "daily";
    timerConfig.Persistent = true;
  };
}
