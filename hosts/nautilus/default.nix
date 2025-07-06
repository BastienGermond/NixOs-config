{...}: {
  imports = [
    ./configuration.nix
    ./system
  ];

  users.extraGroups.plugdev = {};

  users.users.bastien = {
    extraGroups = ["wheel" "audio" "plugdev" "dialout" "scanner" "lp"];
  };
}
