{infra, ...}: let
  anemone = infra.hosts.anemone;
  coral = infra.hosts.coral;
in {
  services.forgejo = {
    stateDir = "/datastore/forgejo";
    settings = {
      server = {
        HTTP_PORT = anemone.ports.gitea;
        HTTP_ADDR = anemone.ips.vpn.A;
        START_SSH_SERVER = true;
        SSH_SERVER_USE_PROXY_PROTOCOL = true;
        BUILTIN_SSH_SERVER_USER = "git";
        SSH_DOMAIN = "git.germond.org";
        SSH_LISTEN_HOST = anemone.ips.vpn.A;
        SSH_LISTEN_PORT = anemone.ports.gitea-ssh;
        SSH_ROOT_PATH = "~/.gitea-ssh";
        SSH_PORT = 22;
        ROOT_URL = "https://git.germond.org";
        # SSH_SERVER_KEY_EXCHANGES = "curve25519-sha256";
      };
      service = {
        DISABLE_REGISTRATION = true;
        DEFAULT_USER_VISIBILITY = "limited";
        DEFAULT_KEEP_EMAIL_PRIVATE = true;
      };
      "service.explore" = {
        REQUIRE_SIGNIN_VIEW = true;
      };
      session = {
        COOKIE_SECURE = true;
      };
      security = {
        REVERSE_PROXY_LIMIT = 1;
        REVERSE_PROXY_TRUSTED_PROXIES = "${coral.ips.vpn.A}";
      };
      openid = {
        ENABLE_OPENID_SIGNIN = false;
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
      createDatabase = true;
      type = "postgres";
      name = "forgejo";
      user = "forgejo";
      socket = "/var/run/postgresql";
    };
  };
}
