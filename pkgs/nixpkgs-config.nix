{ pkgs, ... }:

{
  allowUnfree = true;
  packageOverrides = pkgs: {
    spotibar = pkgs.callPackage (builtins.toPath "/etc/nixos/pkgs/spotibar") {};
  };
}
