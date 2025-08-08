{
  config,
  lib,
  pkgs,
  ...
}: {
  fonts.packages = with pkgs; [
    fira
    font-awesome
    julia-mono
    noto-fonts
    roboto
    termsyn
    # (nerdfonts.override {fonts = ["FiraMono" "FiraCode" "Terminus"];})
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    terminus_font
    liberation_ttf
  ];

  environment.systemPackages = let
    inherit (pkgs) makeDesktopItem;

    lycheeslicer = pkgs.stdenv.mkDerivation (finalAttrs: {
      inherit (pkgs.LycheeSlicer) pname version meta;

      buildInputs = [pkgs.makeWrapper];
      nativeBuildInputs = [pkgs.makeWrapper];
      propagatedBuildInputs = [pkgs.xorg.libxshmfence];

      unpackPhase = "true"; # No source to unpack

      desktopItem = makeDesktopItem {
        name = "LycheeSlicer";
        exec = "LycheeSlicer";
        comment = "All-in-one 3D slicer for Resin and Filament";
        desktopName = "Lychee Slicer";
        categories = ["Graphics"];
      };

      installPhase = ''
        mkdir -p $out/{bin,share}

        install -Dm644 "$desktopItem/share/applications/LycheeSlicer.desktop" "$out/share/applications/LycheeSlicer.desktop"

        makeWrapper ${pkgs.LycheeSlicer}/bin/LycheeSlicer $out/bin/LycheeSlicer \
          --set LD_LIBRARY_PATH ${pkgs.xorg.libxshmfence}/lib
      '';
    });
  in
    with pkgs; [
      adapta-gtk-theme
      alacritty
      arandr
      arduino
      aspell
      aspellDicts.en
      aspellDicts.fr
      bind
      # chitubox-free-bin
      clipit
      cryptsetup
      ctags
      cura-appimage
      curl
      dconf-editor
      evince
      feh
      flameshot
      fritzing
      gcc
      git
      gnumake
      gnupg
      gparted
      gzip
      htop
      iftop
      killall
      libcgroup
      librewolf-wayland
      lycheeslicer
      man-pages
      man-pages-posix
      nautilus
      networkmanagerapplet
      nextcloud-client
      nixpkgs-fmt
      parted
      pavucontrol
      ripgrep
      teamviewer
      thermald
      thunderbird
      tree
      unzip
      usbutils
      wget
      whois
      xsane
      xsel
      zip
      zsh
    ];
}
