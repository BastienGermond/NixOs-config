{
  config,
  lib,
  ...
}: let
  inherit (lib) mkMerge mkIf;
in {
  sops = {
    defaultSopsFile = ./secrets/secrets.yml;

    secrets =
      mkMerge [
      ];
  };
}
