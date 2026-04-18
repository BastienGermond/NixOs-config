{config, pkgs, ...}: let
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
