{ config, pkgs, ... }:

{
  services.nfs.server = {
    enable = true;
  };
}
