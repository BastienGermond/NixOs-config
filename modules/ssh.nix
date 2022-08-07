{ config, pkgs, ... }:

{
  security.pam.enableSSHAgentAuth = true;

  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
}
