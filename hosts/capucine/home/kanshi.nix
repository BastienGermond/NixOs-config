{
  lib,
  my,
  ...
}: {
  config = lib.mkIf my.windowManager.sway.enable {
    services.kanshi.settings = [
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            scale = 1.0;
            position = "0,0";
            status = "enable";
          }
        ];
      }

      {
        profile.name = "home";
        profile.outputs = [
          {
            # Dell U2414H (same unit as nautilus)
            criteria = "Dell Inc. DELL U2414H 9TG465784LAS";
            position = "0,0";
            status = "enable";
          }
          {
            criteria = "eDP-1";
            scale = 1.0;
            position = "0,1080";
            status = "enable";
          }
        ];
      }

      {
        profile.name = "office";
        profile.outputs = [
          {
            # HP V27e — verify exact string with: swaymsg -t get_outputs | jq '.[] | .make + " " + .model'
            criteria = "HP Inc. HP V27e 1CR14203LJ";
            position = "0,0";
            status = "enable";
          }
          {
            criteria = "eDP-1";
            scale = 1.0;
            position = "0,1080";
            status = "enable";
          }
        ];
      }
    ];
  };
}
