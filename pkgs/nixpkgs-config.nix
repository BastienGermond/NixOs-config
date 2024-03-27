{pkgs, ...}: {
  spotibar = pkgs.callPackage (builtins.toPath "./pkgs/spotibar") {};
  freecad-assembly3 = pkgs.callPackage (builtins.toPath "/etc/nixos/pkgs/freecad-assembly3") {};
}
