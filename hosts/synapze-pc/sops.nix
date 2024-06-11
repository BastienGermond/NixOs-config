{
  config,
  lib,
  ...
}: let
  inherit (lib) mkMerge mkIf;
in {
  sops = {
    defaultSopsFile = ./secrets/secrets.yml;

    secrets = mkMerge [
      (mkIf config.services.davfs2.enable {
        nextcloudWebDavSecrets = {
          mode = "0600";
          path = "/etc/davfs2/secrets";
        };
      })
    ];
  };
}
