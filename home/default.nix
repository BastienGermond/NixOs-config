{config, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    sharedModules = [];
    extraSpecialArgs = {inherit (config) my fileSystems;};
    users = {
      "${config.my.mainUser}" = {
        home.stateVersion = "22.05";

        imports = [
          ../hosts/${config.networking.hostName}/home
          ./terminal.nix
          ./dunst.nix
          ./polybar.nix
          ./i3.nix
          ./helix.nix
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
