{ config, pkgs, infra, ... }:

let
  anemone = infra.hosts.anemone;
in
{
  services.postgresql = {
    ensureDatabases = [ "gitea" ];
    ensureUsers = [
      {
        name = "gitea";
        ensurePermissions = {
          "DATABASE \"gitea\"" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  services.gitea = {
    enable = true;
    stateDir = "/datastore/gitea";
    rootUrl = "https://git.germond.org";
    httpPort = anemone.ports.gitea;
    httpAddress = anemone.ips.vpn.A;
    settings = {
      service = {
        DISABLE_REGISTRATION = true;
        DEFAULT_USER_VISIBILITY = "limited";
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
      openid = {
        ENABLE_OPENID_SIGNIN = true;
      };
      oauth2_client = {
        REGISTER_EMAIL_CONFIRM = false;
        ENABLE_AUTO_REGISTRATION = true;
        OPENID_CONNECT_SCOPES = "profile email";
        USERNAME = "nickname";
      };
      log = {
        LEVEL = "Info";
      };
    };
    database = {
      type = "postgres";
      name = "gitea";
      user = "gitea";
      socket = "/var/run/postgresql";
    };
  };
}
