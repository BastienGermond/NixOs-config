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

  users.users.synapze = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/synapze";
    shell = pkgs.zsh;
    extraGroups = ["wheel" "networkmanager" "audio" "vboxusers" "plugdev" "dialout" "scanner" "lp"];
  };

  services.displayManager.autoLogin.user = "synapze";

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
