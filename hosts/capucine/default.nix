{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./configuration.nix
    ./system
  ];

  users.extraGroups.plugdev = {};

  users.users.bastien = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/bastien";
    shell = pkgs.zsh;
    extraGroups = ["wheel" "networkmanager" "audio" "plugdev" "dialout" "scanner" "lp"];
  };

  services.displayManager.autoLogin.user = "bastien";

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.wireguard-tools.out}/bin/wg show";
            options = ["NOPASSWD"];
          }
        ];
        groups = ["wheel"];
      }
    ];
  };
}
