{
  config,
  pkgs,
  ...
}: {
  services.openssh.ports = [2222];

  programs.ssh = {
    startAgent = true;
  };
}
