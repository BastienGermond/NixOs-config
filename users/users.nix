{ config, lib, pkgs, ... }:

let
  home-manager = import ( builtins.fetchTarball "https://github.com/rycee/home-manager/archive/release-21.05.tar.gz" )  { };
in

{
  imports = [ home-manager.nixos ];

  users.users.synapze = {
    uid = 1000;
    isNormalUser = true;
    createHome = true;
    home = "/home/synapze";
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    shell = pkgs.zsh;
  };

  services.xserver.displayManager.autoLogin.user = "synapze";

  security.sudo.extraConfig = ''
synapze ALL = (root) NOPASSWD: ${pkgs.wireguard.out}/bin/wg
  '';

  home-manager.users.synapze = import ./synapze.nix;
  home-manager.users.root = import ./root.nix;
}
