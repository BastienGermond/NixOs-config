{
  pkgs,
  config,
  infra,
  ...
}: let
  coral = infra.hosts.coral;

  keycloak-restrict-client-auth = pkgs.fetchurl {
    url = "https://github.com/sventorben/keycloak-restrict-client-auth/releases/download/v26.1.0/keycloak-restrict-client-auth.jar";
    sha256 = "sha256-3FrEjFcdKtcnQHR8wGOs/rL10U5WNlTi1KU7YIMZbrs=";
  };
in {
  services.keycloak = {
    database = {
      type = "postgresql";
      createLocally = true;

      username = "keycloak";
      passwordFile = config.sops.secrets.keycloakPostgresPassword.path;
    };

    plugins = [
      keycloak-restrict-client-auth
    ];

    settings = {
      hostname = "newsso.germond.org";
      # proxy = "edge";
      proxy-headers = "xforwarded";
      http-host = "127.0.0.1";
      http-port = coral.ports.keycloak;
      http-enabled = true;

      http-management-port = coral.ports.keycloak-management;

      health-enabled = true;
    };
  };
}
