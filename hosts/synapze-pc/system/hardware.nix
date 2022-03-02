{ config, lib, pkgs, ... }:

{
  hardware = {
    #Bluetooth
    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;
    ##for bluetooth headset support
    pulseaudio.package = pkgs.pulseaudioFull;
    pulseaudio.enable = true;
    # Scanner
    sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
    };
  };

  sound.enable = true;
}
