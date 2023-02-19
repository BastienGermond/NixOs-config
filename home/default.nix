{ config, pkgs, lib, inputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    sharedModules = [ ];
    users = {
      synapze = {
        home.stateVersion = "22.05";

        imports = [
          (../hosts/${config.networking.hostName}/home)
          ./git.nix
          ./gpg.nix
          ./neovim.nix
          ./packages.nix
          ./shell.nix
          ./xdg.nix
        ];
      };
    };
  };
}

