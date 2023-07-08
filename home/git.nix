{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.git = {
    enable = false;
  };
}
