{
  config,
  infra,
  ...
}: let
  komgaPort = infra.hosts.anemone.ports.komga;
in {
  users.groups.manga = {};
  
  services.komga = {
    stateDir = "/datastore/komga";
    group = "manga";
    settings = {
      server = {
        port = komgaPort;
      };
      komga = {
        oauth2-account-creation = true;
        oidc-email-verification = false;
      };
      spring = {
        security = {
          oauth2 = {
            client = {
              registration = {
                keycloak = {
                  provider = "keycloak";
                  # client-id: passed by EnvFile
                  # client-secret: passed by EnvFile
                  client-name = "Germond SSO";
                  scope = "openid";
                  authorization-grant-type = "authorization_code";
                  # the placeholders in {} will be replaced automatically, you don't need to change this line
                  redirect-uri = "{baseUrl}/{action}/oauth2/code/{registrationId}";
                };
              };
              provider = {
                keycloak = {
                  issuer-uri = "https://newsso.germond.org/realms/germond";
                  # authorization-uri = "https://newsso.germond.org/realms/germond/protocol/openid-connect/auth";
                  # token-uri = "https://newsso.germond.org/realms/germond/protocol/openid-connect/token";
                  # jwk-set-uri = "https://newsso.germond.org/realms/germond/protocol/openid-connect/certs";
                  # user-info-uri = "https://newsso.germond.org/realms/germond/protocol/openid-connect/userinfo";

                  user-name-attribute = "preferred_username";
                };
              };
            };
          };
        };
      };
    };
  };

  systemd.services.komga.serviceConfig = {
    EnvironmentFile = config.sops.secrets.KomgaSecretsEnvFile.path;
  };
}
