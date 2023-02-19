{ config, pkgs, ... }:

{
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "synapze" ];
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
