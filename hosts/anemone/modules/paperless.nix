{
  config,
  pkgs,
  infra,
  ...
}: {
  services.paperless = {
    enable = true;
    dataDir = "/datastore/paperless";
    port = infra.hosts.anemone.ports.paperless;
    address = infra.hosts.anemone.ips.vpn.A;
    extraConfig = {
      PAPERLESS_ENABLE_HTTP_REMOTE_USER = true;
      PAPERLESS_HTTP_REMOTE_USER_HEADER_NAME = "HTTP_X_AUTHENTIK_USERNAME";
      PAPERLESS_LOGOUT_REDIRECT_URL = "https://paperless.germond.org/outpost.goauthentik.io/sign_out";

      PAPERLESS_URL = "https://paperless.germond.org";
    };
  };

  # systemd.services.paperless-scheduler.after = [ "datastore-paperless.mount" ];
}
