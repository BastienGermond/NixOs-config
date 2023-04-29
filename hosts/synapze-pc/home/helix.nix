{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    # package = (pkgs.helix.overrideAttrs (prev: rec {
    #  version = "23.03"; 
    #  src = pkgs.fetchzip {
    #    url = "https://github.com/helix-editor/helix/releases/download/${version}/helix-${version}-source.tar.xz";
    #    hash = "sha256-FtY2V7za3WGeUaC2t2f63CcDUEg9zAS2cGUWI0YeGwk=";
    #    stripRoot = false;
    #  };
    # }));
    package = pkgs.unstable.helix;
    settings = {
      theme = "everforest_dark";
      editor = {
        line-number = "absolute";
        mouse = false;
        cursorline = true;
        auto-format = true;
      };
    };
    languages = [
      { name = "c"; }
      { name = "cpp"; }
      { name = "nix"; }
      { name = "tsx"; }
      { name = "go"; }
      { name = "cmake"; }
    ];
  };
}
