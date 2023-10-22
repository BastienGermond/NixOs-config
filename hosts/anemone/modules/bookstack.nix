{
  config,
  pkgs,
  ...
}: {
  services.bookstack = {
    enable = true;
    hostname = "docs.germond.org";
    dataDir = "/datastore/bookstack";
    appURL = "https://docs.germond.org";
    appKeyFile = config.sops.secrets.BookstackAppKey.path;

    database = {
      user = "bookstack";
      host = "localhost";
      name = "bookstack";

      createLocally = true;
    };

    config = {
      AUTH_METHOD = "oidc";
      AUTH_AUTO_INITIATE = true;
      OIDC_NAME = ''"Germond SSO"'';
      OIDC_CLIENT_ID = "bookstack";
      OIDC_CLIENT_SECRET._secret = config.sops.secrets.BookstackOIDCSecret.path;
      OIDC_ISSUER = "https://newsso.germond.org/realms/germond";
      OIDC_ISSUER_DISCOVER = true;
      OIDC_USER_TO_GROUPS = true;
      OIDC_GROUPS_CLAIM = "bookstack.roles";
      # OIDC_ADDITIONAL_SCOPES = "groups";
      OIDC_REMOVE_FROM_GROUPS = true;
      OIDC_DISPLAY_NAME_CLAIMS = "name";

      STORAGE_TYPE = "s3";
      STORAGE_S3_KEY = "bookstack";
      STORAGE_S3_SECRET._secret = config.sops.secrets.BookstackS3Secret.path;
      STORAGE_S3_BUCKET = "bookstack";
      STORAGE_S3_REGION = "eu-west-3";

      STORAGE_S3_ENDPOINT = "https://s3.germond.org";
      STORAGE_URL = "https://s3.germond.org/bookstack";

      # APP_DEBUG = true;
    };
  };

  services.mysql = {
    package = pkgs.mariadb;
    enable = true;
  };
}
