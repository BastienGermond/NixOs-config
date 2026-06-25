{
  pkgs,
  my,
  lib,
  ...
}: {
  config = {
    home.packages =
      (with pkgs; [
        any-nix-shell
        bat
        binutils
        ccls
        clang-tools
        file
        fzf
        gtop
        jq
        libnotify
        ncdu
        nvd
        picocom
      ])
      ++ lib.optionals (!my.isAServer) (with pkgs; [
        claude-code
        rtk
      ]);
  };
}
