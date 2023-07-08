{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./configuration.nix
    ./modules
  ];

  users.extraGroups.plugdev = {};

  users.users.synapze = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/synapze";
    shell = pkgs.zsh;
    extraGroups = ["wheel" "networkmanager" "audio" "vboxusers" "plugdev" "dialout" "scanner" "lp"];
  };
}
