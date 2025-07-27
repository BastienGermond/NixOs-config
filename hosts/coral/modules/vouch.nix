{
  config,
  ...
}: {
  services.vouch-proxy = {
    envFile = config.sops.secrets.vouchProxyEnv.path;

    settings = {
      vouch = {
        testing = false;
        logLevel = "info";
        listen = "127.0.0.1";
        port = 9090;
        allowAllUsers = true;
        cookie = {
          secure = true;
          domain = "germond.org";
        };

        headers = {
          claims = ["groups"];
        };
      };

      oauth = {
        provider = "oidc";
        client_id = "vouch-proxy";
        auth_url = "https://newsso.germond.org/realms/germond/protocol/openid-connect/auth";
        token_url = "https://newsso.germond.org/realms/germond/protocol/openid-connect/token";
        user_info_url = "https://newsso.germond.org/realms/germond/protocol/openid-connect/userinfo";
        end_session_endpoint = "https://newsso.germond.org/realms/germond/protocol/openid-connect/logout";
        scopes = ["openid" "email" "profile"];
        callback_url = "https://vouch.germond.org/auth";
        code_challenge_method = "S256";
      };
    };
  };
}
