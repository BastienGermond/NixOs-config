{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
  ];
}
