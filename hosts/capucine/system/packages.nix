{pkgs, ...}: let
  routed-gothic = pkgs.stdenv.mkDerivation {
    pname = "routed-gothic";
    version = "1.0.0";

    src = pkgs.fetchzip {
      url = "https://github.com/dse/routed-gothic/raw/4f90a75bb7b388006a63d2d63d7c55b0509acdaf/download/routed-gothic-ttf-v1.0.0.zip";
      hash = "sha256-R7EaYsi1Q854qoOgXOl0RWohSAkLfYcriCzaeh9WgXo=";
    };

    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp *.ttf $out/share/fonts/truetype/
    '';
  };
in {
  fonts.packages = with pkgs; [
    fira
    font-awesome
    julia-mono
    liberation_ttf
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    # (nerdfonts.override {fonts = ["FiraMono" "FiraCode" "Terminus"];})
    noto-fonts
    overpass
    roboto
    routed-gothic
    terminus_font
    termsyn
  ];

  environment.systemPackages = let
    inherit (pkgs) makeDesktopItem;

    lycheeslicer = pkgs.lycheeslicer;
    # pkgs.stdenv.mkDerivation (finalAttrs: {
    #   inherit (pkgs.LycheeSlicer) pname version meta;
    #   buildInputs = [pkgs.makeWrapper];
    #   nativeBuildInputs = [pkgs.makeWrapper];
    #   propagatedBuildInputs = [pkgs.xorg.libxshmfence];
    #   unpackPhase = "true"; # No source to unpack
    #   desktopItem = makeDesktopItem {
    #     name = "LycheeSlicer";
    #     exec = "LycheeSlicer";
    #     comment = "All-in-one 3D slicer for Resin and Filament";
    #     desktopName = "Lychee Slicer";
    #     categories = ["Graphics"];
    #   };
    #   installPhase = ''
    #     mkdir -p $out/{bin,share}
    #     install -Dm644 "$desktopItem/share/applications/LycheeSlicer.desktop" "$out/share/applications/LycheeSlicer.desktop"
    #     makeWrapper ${pkgs.LycheeSlicer}/bin/LycheeSlicer $out/bin/LycheeSlicer \
    #       --set LD_LIBRARY_PATH ${pkgs.xorg.libxshmfence}/lib
    #   '';
    # });
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
      librewolf
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
