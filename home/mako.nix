{
  lib,
  my,
  ...
}: {
  config = lib.mkIf my.windowManager.sway.enable {
    services.mako = {
      enable = true;

      settings = {
        font = "FiraCode Nerd Font 11";

        width = 600;
        height = 100;

        margin = "10";
        padding = "10";

        border-size = 3;

        max-visible = 5;

        default-timeout = 5000;

        sort = "-time";

        layer = "top";
        anchor = "top-right";

        format = "<b>%s</b>\\n%b";

        markup = true;

        on-button-left = "dismiss";
        on-button-right = "invoke-default-action";

        background-color = "#282828";
        text-color = "#ebdbb2";
        border-color = "#458588";

        "urgency=low" = {
          background-color = "#282828";
          text-color = "#928374";
          default-timeout = 5;
        };

        "urgency=normal" = {
          background-color = "#458588";
          text-color = "#ebdbb2";
          default-timeout = 5;
        };

        "urgency=critical" = {
          background-color = "#cc2421";
          text-color = "#ebdbb2";
          border-color = "#fabd2f";
          default-timeout = 0;
        };

        "mode=do-not-disturb" = {
          invisible = true;
        };
      };
    };
  };
}
