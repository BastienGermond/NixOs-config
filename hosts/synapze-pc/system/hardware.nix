{ config, lib, pkgs, ... }:

{
  hardware = {
    #Bluetooth
    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;
    ##for bluetooth headset support
    pulseaudio.package = pkgs.pulseaudioFull;
    pulseaudio.enable = true;
  };

  sound.enable = true;
}
