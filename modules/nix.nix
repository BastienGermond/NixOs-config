{ config, pkgs, ... }:

{
  nix = {
    settings.trusted-users = [ "synapze" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
