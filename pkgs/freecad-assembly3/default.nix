{ pkgs, fetchFromGitHub }:

let
  override = super: {
    version = "0.11";

    src = fetchFromGitHub {
      owner = "realthunder";
      repo = "FreeCAD_assembly3";
      rev = "0.11";
      sha256 = "0f5v35gwvn96m867l7cd0jfk5cix9mb08sclc2fvvppns67wajcv";
      fetchSubmodules = true;
    };
  };
in
pkgs.freecad.overrideAttrs (override)
