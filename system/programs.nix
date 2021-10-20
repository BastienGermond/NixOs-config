{ config, pkgs, ... }:

{
  # Disabled for gpg-agent
  programs.ssh.startAgent = false;

  # Manage backlight without xserver
  # e.g light -U 30 (darker) light -A 30 (lighter)
  programs.light.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.nm-applet.enable = true;
  programs.nm-applet.indicator = true;
}
