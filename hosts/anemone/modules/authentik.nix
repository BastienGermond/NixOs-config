{ config, pkgs, ... }:

{
  users.groups.authentik.gid = 568;
  users.users.authentik = {
    isSystemUser = true;
    createHome = false;
    uid = 568;
    group = "authentik";
  };

  # PostgreSQL DB
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
    ensureDatabases = [ "authentik" ];
  };

  # Redis
  services.redis.servers.redis-authentik = {
    enable = true;
    port = 6379;
  };

  virtualisation.oci-containers.containers = {
    authentik-server = {
      autoStart = true;
      user = "568:568";
      image = "ghcr.io/goauthentik/server:2022.7.3";
      cmd = [ "server" ];
      extraOptions = [ "--network=host" ];
      environment = {
        AUTHENTIK_REDIS__HOST = "localhost";

        AUTHENTIK_POSTGRESQL__HOST = "localhost";
        AUTHENTIK_POSTGRESQL__USER = "postgres";
        AUTHENTIK_POSTGRESQL__NAME = "authentik";
        AUTHENTIK_POSTGRESQL__PASSWORD = "";
      };
      volumes = [
        # "geoip:/geoip"
      ];
    };

    geoip = {
      autoStart = true;
      image = "maxmindinc/geoipupdate:latest";
      environment = {
        GEOIPUPDATE_EDITION_IDS = "GeoLite2-City";
        GEOIPUPDATE_FREQUENCY = "8";
      };
      volumes = [
        "geoip:/usr/share/GeoIP"
      ];
    };
  };
}
