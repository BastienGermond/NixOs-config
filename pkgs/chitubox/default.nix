{pkgs ? import <nixpkgs> {}}: let
  steam-run = pkgs.steam-run-native;
in
  pkgs.stdenv.mkDerivation {
    pname = "chitubox-free-bin";
    version = "2.3.0";

    src = pkgs.fetchurl {
      url = "https://sac.chitubox.com/software/download.do?installerUrl=https://download.chitubox.com/17839/v2.3.0/CHITUBOX_Basic_Linux_Installer_V2.3.tar.gz&softwareId=17839&softwareVersionId=v2.3.0";
      sha256 = "sha256-RM8Y+EaPvKtpF52WIiMrGHomPZ+iXFObXWvCCXlOyTs=";
    };

    buildInputs = [
      steam-run
    ];

    unpackPhase = ''
      mkdir -p $TMPDIR/source
      cd $TMPDIR/source
      tar -xzf $src
      ls -la
    '';

    installPhase = let
      runtimeLibs = pkgs.lib.makeLibraryPath [
        pkgs.xorg.libX11
        pkgs.xorg.libxcb
        pkgs.xorg.xcbutil
        pkgs.xorg.xcbutilwm
        pkgs.xorg.xcbutilimage
        pkgs.xorg.xcbutilkeysyms
        pkgs.xorg.xcbutilrenderutil
        pkgs.zstd
        pkgs.libxkbcommon
        pkgs.dbus
        pkgs.fontconfig
        pkgs.zlib
        pkgs.bzip2
        pkgs.xz
        pkgs.freetype
        pkgs.gcc
        pkgs.stdenv.cc.cc.lib
      ];
    in
      # bash
      ''
        export INSTALL_ROOT=$TMPDIR/CHITUBOX_Basic
        export OPT_DIR=$out/opt
        export APP_DIR=$OPT_DIR/CHITUBOX_Basic

        ls -la $TMPDIR/source

        if [ ! -f $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run ]; then
          echo "File not found"
          exit 1
        fi

        chmod +x $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run

        # ldd $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run

        $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run --noexec --target $TMPDIR/extracted

        LD_LIBRARY_PATH=${runtimeLibs}:$LD_LIBRARY_PATH \
        ${steam-run}/bin/steam-run $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run \
          --root $INSTALL_ROOT \
          --accept-licenses \
          --no-size-checking \
          --accept-messages \
          --confirm-command install

        # $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run --nox11 --list
        # $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run --list

        # $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run --target $APP_DIR --noexec --nox11 --nodiskspace

        # ${steam-run}/bin/steam-run $TMPDIR/source/CHITUBOX_Basic_Linux_Installer_V2.3.run --root $INSTALL_ROOT --accept-licenses --no-size-checking --accept-messages --confirm-command install
      '';

    meta = with pkgs.lib; {
      description = "All-in-one SLA/DLP/LCD Slicer";
      homepage = "https://www.chitubox.com/download.html";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  }
