{ pkgs, ... }:

{
  spotibar = pkgs.callPackage (builtins.toPath "./pkgs/spotibar") { };
  super-slicer = pkgs.callPackage (builtins.toPath "/etc/nixos/pkgs/super-slicer") { };
  freecad-assembly3 = pkgs.callPackage (builtins.toPath "/etc/nixos/pkgs/freecad-assembly3") { };
}
