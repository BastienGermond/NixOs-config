{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
  ];

  users.extraGroups.plugdev = { };

  users.users.synapze = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/synapze";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "audio" "vboxusers" "plugdev" "dialout" "scanner" "lp" ];
  };

  services.xserver.displayManager.autoLogin.user = "synapze";

  security.sudo.extraConfig = ''
  synapze ALL = (root) NOPASSWD: ${pkgs.wireguard-tools.out}/bin/wg
  '';

}
