{pkgs, ...}: {
  hardware = {
    #Bluetooth
    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;
    # Scanner
    sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
    };
  };

  services.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };
}
