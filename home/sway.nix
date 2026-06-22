{
  config,
  lib,
  my,
  ...
}: {
  config = lib.mkIf my.windowManager.sway.enable {
    services.kanshi = {
      enable = true;

      settings = [
        {
          profile.name = "laptop";
          profile.outputs = [
            {
              criteria = "eDP-1";
              scale = 1.5;
              position = "0,0";
              status = "enable";
            }
          ];
        }

        {
          profile.name = "home";
          profile.outputs = [
            {
              criteria = "Dell Inc. DELL U2414H 9TG465784LAS";
              # scale = 1.0;
              position = "0,0";
              status = "enable";
            }

            {
              criteria = "eDP-1";
              scale = 1.5;
              position = "0,1080";
              status = "enable";
            }
          ];
        }
      ];
    };

    wayland.windowManager.sway = let
      workspaceMap = {
        "1" = "term";
        "2" = "www";
        "3" = "social";
      };

      workspaceNumbers = builtins.genList (n: toString (n + 1)) 9;

      workspaceKeybindings = builtins.concatLists (builtins.map (
          num: let
            label = workspaceMap.${num} or null;
            name =
              if label != null
              then "${num}:${label}"
              else num;
          in [
            {
              key = "Mod4+" + num;
              command = "workspace " + name;
            }
            {
              key = "Mod4+Shift+" + num;
              command = "move container to workspace " + name;
            }
          ]
        )
        workspaceNumbers);

      mod = config.wayland.windowManager.sway.config.modifier;
    in {
      enable = true;

      config = {
        modifier = "Mod4";
        terminal = "alacritty";

        fonts = {
          names = ["monospace"];
          size = 13.0;
        };

        keybindings =
          {
            "${mod}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
            "${mod}+Shift+q" = "kill";
            "${mod}+d" = "exec wofi --show drun";
            "${mod}+Shift+Return" = "exec $BROWSER";

            # Audio
            "XF86AudioRaiseVolume" = "exec amixer -q set Master 5%+ unmute";
            "XF86AudioLowerVolume" = "exec amixer -q set Master 5%- unmute";
            "XF86AudioMute" = "exec amixer -q set Master toggle";

            # Screenshot
            # "Print" = "exec grim -g \"$(slurp)\" - | wl-copy";
            "Print" = "exec flameshot gui";

            # Notifications
            "${mod}+0" = "exec makoctl history";

            "${mod}+p" = "move workspace to output up";

            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+r" = "restart";

            # Exit
            "${mod}+Shift+e" = "exec swaymsg exit";

            "${mod}+r" = "mode resize";

            # Layout
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+v" = "split vertical";
            "${mod}+h" = "split horizontal";

            # Focus
            "${mod}+Left" = "focus left";
            "${mod}+Right" = "focus right";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";

            # Move
            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Right" = "move right";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";

            # Floating
            "${mod}+Shift+space" = "floating toggle";
          }
          // builtins.listToAttrs (builtins.map (b: {
              name = b.key;
              value = b.command;
            })
            workspaceKeybindings);

        workspaceAutoBackAndForth = true;

        startup = [
          {command = "nm-applet";}
          {command = "mako";}
          {command = "kanshi";}
          {command = "waybar";}
          {command = "flameshot";}
        ];

        assigns = {
          "2:www" = [{app_id = "librewolf";}];
          "3:social" = [
            {app_id = "thunderbird";}
            {app_id = "discord";}
            {app_id = "Slack";}
          ];
        };

        window.commands = let
          makeMatch = type: value: command: {
            criteria = builtins.listToAttrs [
              {
                name = type;
                value = value;
              }
            ];
            inherit command;
          };

          makeMatchTitle = makeMatch "title";
          makeMatchClass = makeMatch "class";
          makeMatchWindowRole = makeMatch "window_role";
          makeMatchInstance = makeMatch "instance";
        in [
          (makeMatchClass "GParted" "floating enable border normal")
          (makeMatchClass "Nm-connection-editor" "floating enable")
          (makeMatchClass "org.gnome.Nautilus" "floating enable resize set 50ppt 60ppt")
          (makeMatchClass "pavucontrol" "floating enable resize set 50ppt 60ppt move position center")
          (makeMatchClass "Qemu-system-x86_64" "floating enable")
          (makeMatchInstance "flameshot" "floating enable")
          (makeMatchTitle "^3D Viewer.*$" "floating enable border normal resize set 50ppt 60ppt")
          (makeMatchTitle "alsamixer" "floating enable border pixel 1")
          (makeMatchWindowRole "About" "floating enable")
          (makeMatchWindowRole "EventSummaryDialog" "floating enable")
          (makeMatchWindowRole "pop-up" "floating enable")
          {
            criteria = {
              app_id = "thunderbird";
              title =  ".*[Pp]assword.*";
            };
            command = "floating enable";
          }
        ];

        modes = {
          resize = {
            "Left" = "resize shrink width 10 px or 10 ppt";
            "Down" = "resize grow height 10 px or 10 ppt";
            "Up" = "resize shrink height 10 px or 10 ppt";
            "Right" = "resize grow width 10 px or 10 ppt";
            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };

        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            xkb_variant = "alt-intl";
          };

          "type:touchpad" = {
            natural_scroll = "enabled";
            tap = "enabled";
            drag_lock = "disabled";
            pointer_accel = "1.0";
          };

          "type:mouse" = {
            tap = "disabled";
            drag_lock = "disabled";
          };
        };

        bars = [];
      };
    };
  };
}
