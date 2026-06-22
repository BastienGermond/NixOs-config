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
          ./dunst.nix
          ./git.nix
          ./gpg.nix
          ./helix.nix
          ./i3.nix
          ./mako.nix
          ./neovim.nix
          ./packages.nix
          ./polybar.nix
          ./shell.nix
          ./sway.nix
          ./terminal.nix
          ./waybar.nix
          ./wofi.nix
          ./xdg.nix
        ];
      };
    };
  };
}
