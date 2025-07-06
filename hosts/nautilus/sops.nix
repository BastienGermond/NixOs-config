{lib, ...}: let
  inherit (lib) mkMerge;
in {
  sops = {
    defaultSopsFile = ./secrets/secrets.yml;

    secrets =
      mkMerge [
      ];
  };
}
