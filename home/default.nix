{ config, pkgs, inputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    sharedModules = [ ];
    users = {
      synapze = {
        home.stateVersion = "22.05";
        imports = [
          ./packages.nix
          ./xdg.nix
          ./shell.nix
          ./terminal.nix
          ./neovim.nix
          ./rofi.nix
          ./git.nix
        ];
      };
    };
  };
}

