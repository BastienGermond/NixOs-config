{ isMinimal }:

{ config, pkgs, lib, inputs, ... }:

{
  config = {
    home.packages = lib.mkMerge [
      (with pkgs; [
        any-nix-shell
        bat
        binutils
        ccls
        clang-tools
        cura
        discord
        dunst
        file
        fzf
        gtop
        jq
        libnotify
        ncdu
        picocom
        rnix-lsp
        rofi
        scrot
      ])

      (lib.mkIf (isMinimal == false) (with pkgs; [
        docker-buildx
        spotify
        spotibar
        drawio
        firefox
        freecad
        gimp
        inkscape
        kicad
        languagetool
        libreoffice
        nodePackages.eslint
        nodePackages.prettier
        nodePackages.typescript-language-server
        signal-desktop
        slack
        stm32cubemx
        super-slicer
        teams
        texlab
      ]))
    ];
  };
}
