{ config, pkgs, inputs, ... }:

{
  services.gpg-agent.extraConfig = ''
    allow-loopback-pinentry
  '';
}
