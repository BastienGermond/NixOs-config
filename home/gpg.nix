{
  config,
  pkgs,
  inputs,
  ...
}: {
  services.gpg-agent.extraConfig = ''
  '';
}
