{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./modules
  ];

  users.users.synapze = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/synapze";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
