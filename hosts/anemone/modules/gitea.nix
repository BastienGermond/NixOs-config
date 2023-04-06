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
      server = {
        START_SSH_SERVER = true;
        BUILTIN_SSH_SERVER_USER = "git";
        SSH_DOMAIN = "git.germond.org";
        SSH_LISTEN_HOST = anemone.ips.vpn.A;
        SSH_LISTEN_PORT = anemone.ports.gitea-ssh;
        SSH_ROOT_PATH = "~/.gitea-ssh";
        SSH_PORT = 22;
        # SSH_SERVER_KEY_EXCHANGES = "curve25519-sha256";
      };
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
        LEVEL = "Debug";
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
