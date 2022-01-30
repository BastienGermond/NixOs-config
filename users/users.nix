{ config, lib, pkgs, ... }:

{
  users.extraGroups.plugdev = { };

  users.users.synapze = {
    uid = 1000;
    isNormalUser = true;
    createHome = true;
    home = "/home/synapze";
    extraGroups = [ "wheel" "networkmanager" "audio" "vboxusers" "plugdev" "dialout" ];
    shell = pkgs.zsh;
  };

  services.xserver.displayManager.autoLogin.user = "synapze";

  security.sudo.extraConfig = ''
synapze ALL = (root) NOPASSWD: ${pkgs.wireguard.out}/bin/wg
  '';
}
