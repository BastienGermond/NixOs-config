{pkgs, ...}: {
  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;
    sane = {
      enable = false;
      extraBackends = [pkgs.sane-airscan];
    };
  };
}
