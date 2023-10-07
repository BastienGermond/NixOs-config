{
  config,
  pkgs,
  ...
}: {
  services.deluge = {
    enable = true;
    dataDir = "/datastore/deluge";
    declarative = true;

    config = {
      # TBD: TBD: outgoing_interface = "pia";
    };

    authFile = config.sops.secrets.DelugeAuth.path;

    web = {
      enable = true;
    };
  };
}
