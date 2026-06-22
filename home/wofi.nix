{
  lib,
  my,
  ...
}: {
  config = lib.mkIf my.windowManager.sway.enable {
    programs.wofi = {
      enable = true;

      style = ''
        * {
          font-family: "FiraCode Nerd Font";
          font-size: 15px;
        }
      '';
    };
  };
}
