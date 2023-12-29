{
  config,
  pkgs,
  infra,
  ...
}: let
  anemone = infra.hosts.anemone;
in {
  services.peertube = {
    enable = true;
    listenWeb = 443;
    enableWebHttps = true;
    redis.createLocally = true;
    localDomain = "videos.germond.org";
    listenHttp = anemone.ports.peertube;
    database.createLocally = true;
    secrets.secretsFile = config.sops.secrets.PeertubeSecret.path;
    dataDirs = [
      "/datastore/peertube"
    ];
    configureNginx = true;
    settings = {
      storage = {
        tmp = "/var/lib/peertube/storage/tmp/";
        tmp_persistent = "/var/lib/peertube/storage/tmp_persistent/";
        bin = "/datastore/peertube/storage/bin/";
        avatars = "/datastore/peertube/storage/avatars/";
        videos = "/datastore/peertube/storage/videos/";
        streaming_playlists = "/datastore/peertube/storage/streaming-playlists/";
        redundancy = "/datastore/peertube/storage/redundancy/";
        logs = "/var/lib/peertube/storage/logs/";
        previews = "/datastore/peertube/storage/previews/";
        thumbnails = "/datastore/peertube/storage/thumbnails/";
        torrents = "/datastore/peertube/storage/torrents/";
        captions = "/datastore/peertube/storage/captions/";
        cache = "/var/lib/peertube/storage/cache/";
        plugins = "/datastore/peertube/storage/plugins/";
        well_known = "/var/lib/peertube/storage/well_known/";
        client_overrides = "/var/lib/peertube/storage/client-overrides/";
      };

      log = {
        level = "info";
      };

      followers = {
        instance = {
          enabled = false;
          manual_approval = true;
        };
      };

      signup = {
        enabled = false;
      };

      defaults = {
        publish = {
          # public = 1, unlisted = 2, private = 3, internal = 4
          privacy = 4;
        };

        p2p = {
          webapp = {
            enabled = false;
          };

          embed = {
            enabled = false;
          };
        };
      };

      remote_redundancy = {
        videos = {
          accept_from = "nobody";
        };
      };
    };
  };
}
