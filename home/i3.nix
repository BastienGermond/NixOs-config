{
  config,
  lib,
  my,
  ...
}: {
  config = lib.mkIf my.i3.enable {
    xsession.windowManager.i3 = let
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
            "${config.xsession.windowManager.i3.config.modifier}+Return" = "exec ${config.xsession.windowManager.i3.config.terminal}";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+q" = "kill";
            "${config.xsession.windowManager.i3.config.modifier}+d" = "exec rofi -show drun -font 'FiraCode Nerd Font 15'";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+Return" = "exec $BROWSER";
            "XF86AudioRaiseVolume" = "exec amixer -q set Master 5%+ unmute";
            "XF86AudioLowerVolume" = "exec amixer -q set Master 5%- unmute";
            "XF86AudioMute" = "exec amixer -q set Master toggle";
            "Print" = "exec flameshot gui";
            "${config.xsession.windowManager.i3.config.modifier}+0" = "exec dunstctl history-pop";
            "${config.xsession.windowManager.i3.config.modifier}+p" = "move workspace to output up";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+c" = "reload";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+r" = "restart";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+e" = ''exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"'';

            "${config.xsession.windowManager.i3.config.modifier}+r" = "mode resize";

            # Change layout
            "${config.xsession.windowManager.i3.config.modifier}+s" = "layout stacking";
            "${config.xsession.windowManager.i3.config.modifier}+w" = "layout tabbed";
            "${config.xsession.windowManager.i3.config.modifier}+e" = "layout toggle split";
            "${config.xsession.windowManager.i3.config.modifier}+f" = "fullscreen toggle";
            "${config.xsession.windowManager.i3.config.modifier}+v" = "split vertical";
            "${config.xsession.windowManager.i3.config.modifier}+h" = "split horizontal";

            # Focus
            "${config.xsession.windowManager.i3.config.modifier}+Left" = "focus left";
            "${config.xsession.windowManager.i3.config.modifier}+Right" = "focus right";
            "${config.xsession.windowManager.i3.config.modifier}+Down" = "focus down";
            "${config.xsession.windowManager.i3.config.modifier}+Up" = "focus up";

            # Move
            "${config.xsession.windowManager.i3.config.modifier}+Shift+Left" = "move left";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+Right" = "move right";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+Down" = "move down";
            "${config.xsession.windowManager.i3.config.modifier}+Shift+Up" = "move up";

            # Toggle floating
            "${config.xsession.windowManager.i3.config.modifier}+Shift+space" = "floating toggle";
          }
          // builtins.listToAttrs (builtins.map (b: {
              name = b.key;
              value = b.command;
            })
            workspaceKeybindings);

        workspaceAutoBackAndForth = true;
        startup = [
          {command = "xss-lock --transfer-sleep-lock -- i3lock --nofork";}
          {command = "nm-applet";}
          {command = "clipit -d";}
          {command = "flameshot";}
          {
            command = "systemctl --user restart polybar";
            always = true;
          }
        ];

        assigns = {
          "2:www" = [{class = "librewolf";}];
          "3:social" = [
            {class = "thunderbird";}
            {class = "discord";}
            {class = "Slack";}
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

        bars = []; # Let polybar handle this
      };
    };
  };
}
