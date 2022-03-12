{ config, pkgs, inputs, ... }:

{
  programs.rofi = {
    enable = true;
    font = "Terminus (TTF) 12";
  };
}
