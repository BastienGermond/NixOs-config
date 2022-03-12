{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
}

