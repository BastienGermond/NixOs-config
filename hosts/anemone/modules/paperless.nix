{ config, pkgs, ... }:

{
  services.paperless = {
    enable = true;
    dataDir = "/datastore/paperless";
    port = 28981;
    address = "10.100.10.2";
    extraConfig = {
      PAPERLESS_ENABLE_HTTP_REMOTE_USER = true;
      PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = "HTTP_X_AUTHENTIK_USERNAME";
      PAPERLESS_LOGOUT_REDIRECT_URL = "https://paperless.germond.org/outpost.goauthentik.io/sign_out";

      PAPERLESS_URL = "https://paperless.germond.org";
    };
  };

  # systemd.services.paperless-scheduler.after = [ "datastore-paperless.mount" ];
}
