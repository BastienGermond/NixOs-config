{ pkgs, config, infra, ... }:

let
  coral = infra.hosts.coral;
in
{
  services.keycloak = {
    enable = true;

    database = {
      type = "postgresql";
      createLocally = true;

      username = "keycloak";
      passwordFile = config.sops.secrets.keycloakPostgresPassword.path;
    };

    settings = {
      hostname = "newsso.germond.org";
      proxy = "edge";
      http-host = "127.0.0.1";
      http-port = coral.ports.keycloak;
      http-enabled = true;
    };
  };
}
