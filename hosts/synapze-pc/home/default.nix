{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./dunst.nix
    ./helix.nix
    ./polybar.nix
    ./rofi.nix
    ./terminal.nix
  ];

  config = {
    home.packages = with pkgs; [
      amber
      attic-client
      cmake-language-server
      cura
      discord
      docker-buildx
      drawio
      dunst
      firefox
      freecad
      gimp
      gopls
      helix
      inkscape
      kicad
      languagetool
      libreoffice
      nodePackages.eslint
      nodePackages.prettier
      nodePackages.typescript-language-server
      rofi
      scrot
      signal-desktop
      slack
      # spotibar
      spotify
      stm32cubemx
      # super-slicer
      teams-for-linux
      texlab
    ];
  };
}
