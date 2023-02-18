{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.services.postgresqlCipheredBackup;

  postgresqlBackupService = db: dumpCmd:
    let
      compressSuffixes = {
        "none" = "";
        "gzip" = ".gz";
        "zstd" = ".zstd";
      };
      compressSuffix = getAttr cfg.compression compressSuffixes;

      compressCmd = getAttr cfg.compression {
        "none" = "cat";
        "gzip" = "${pkgs.gzip}/bin/gzip -c -${toString cfg.compressionLevel}";
        "zstd" = "${pkgs.zstd}/bin/zstd -c -${toString cfg.compressionLevel}";
      };

      cipherCmd = "${pkgs.gnupg}/bin/gpg --encrypt --armor --trust-model always -r ${cfg.gpgKeyID}";

      mkSqlPath = prefix: suffix: "${cfg.location}/${db}${prefix}.sql${suffix}";
      curFile = mkSqlPath "" compressSuffix;
      prevFile = mkSqlPath ".prev" compressSuffix;
      prevFiles = map (mkSqlPath ".prev") (attrValues compressSuffixes);
      inProgressFile = mkSqlPath ".in-progress" compressSuffix;

      s3UploadCmd = ''
        ${pkgs.s3cmd}/bin/s3cmd --config=${cfg.s3.configFile} put ${prevFile} \
        s3://${cfg.s3.bucket}/${builtins.baseNameOf prevFile}
        ${pkgs.s3cmd}/bin/s3cmd --config=${cfg.s3.configFile} put ${curFile} \
        s3://${cfg.s3.bucket}/${builtins.baseNameOf curFile}
      '';
    in
    {
      enable = true;

      description = "Backup of ${db} database(s)";

      requires = [ "postgresql.service" ];

      path = [ pkgs.coreutils config.services.postgresql.package pkgs.s3cmd];

      script = ''
          set -e -o pipefail

          umask 0077 # ensure backup is only readable by postgres user

          if [ -e ${curFile} ]; then
            rm -f ${toString prevFiles}
            mv ${curFile} ${prevFile}
          fi

          # ensure that we have imported key
          ${pkgs.gnupg}/bin/gpg --recv-keys ${cfg.gpgKeyID}

          ${dumpCmd} \
            | ${compressCmd} \
            | ${cipherCmd} \
            > ${inProgressFile}

          mv ${inProgressFile} ${curFile}
      '' + (if cfg.s3.enable then s3UploadCmd else "");

      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
      };

      startAt = cfg.startAt;
    };
in
{
  options = {
    services.postgresqlCipheredBackup = {
      enable = mkEnableOption "Postgresql Ciphered Backup";

      gpgKeyID = mkOption {
        type = types.str;
        description = "KeyID to be used as gpg recipient for encryption.";
      };

      startAt = mkOption {
        default = "*-*-* 01:15:00";
        type = with types; either (listOf str) str;
        description = lib.mdDoc ''
          This option defines (see `systemd.time` for format) when the
          databases should be dumped.
          The default is to update at 01:15 (at night) every day.
        '';
      };

      databases = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = lib.mdDoc ''
          List of database names to dump.
        '';
      };

      location = mkOption {
        default = "/var/backup/postgresql";
        type = types.path;
        description = lib.mdDoc ''
          Path of directory where the PostgreSQL database dumps will be placed.
        '';
      };

      pgdumpOptions = mkOption {
        type = types.separatedString " ";
        default = "-C";
        description = lib.mdDoc ''
          Command line options for pg_dump.
        '';
      };

      compression = mkOption {
        type = types.enum [ "none" "gzip" "zstd" ];
        default = "gzip";
        description = lib.mdDoc ''
          The type of compression to use on the generated database dump.
        '';
      };

      compressionLevel = mkOption {
        type = types.ints.between 1 19;
        default = 6;
        description = lib.mdDoc ''
          The compression level used when compression is enabled.
          gzip accepts levels 1 to 9. zstd accepts levels 1 to 19.
        '';
      };

      s3 = {
        enable = mkEnableOption "S3 automatic backup upload";

        bucket = mkOption {
          type = types.str;
          description = "S3 bucket";
        };

        configFile = mkOption {
          type = types.path;
          description = "s3cmd compatible configuration file";
        };
      };
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.compression == "none" ||
            (cfg.compression == "gzip" && cfg.compressionLevel >= 1 && cfg.compressionLevel <= 9) ||
            (cfg.compression == "zstd" && cfg.compressionLevel >= 1 && cfg.compressionLevel <= 19);
          message = "config.services.postgresqlCipheredBackup.compressionLevel must be set between 1 and 9 for gzip and 1 and 19 for zstd";
        }
      ];
    }

    (mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d '${cfg.location}' 0700 postgres - - -"
      ];
    })

    (mkIf (cfg.enable) {
      systemd.services = listToAttrs (map
        (db:
          let
            cmd = "pg_dump ${cfg.pgdumpOptions} ${db}";
          in
          {
            name = "postgresqlCipheredBackup-${db}";
            value = postgresqlBackupService db cmd;
          })
        cfg.databases);
    })
  ];
}
