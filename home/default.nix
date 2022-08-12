{ isMinimal ? false }:
{ config, pkgs, inputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    sharedModules = [ ];
    users = {
      synapze = {
        home.stateVersion = "22.05";
        imports = [
          (import ./packages.nix { inherit isMinimal; })
          ./xdg.nix
          ./gpg.nix
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

