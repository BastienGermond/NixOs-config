{
  pkgs,
  my,
  ...
}: {
  services.dunst = {
    enable = my.i3.dunst.enable;
    settings = {
      global = {
        monitor = 0;
        font = "FiraCode Nerd Font 11";
        follow = "keyboard";
        width = 600;
        height = 100;
        indicate_hidden = true;
        shrink = true;
        transparency = 14;
        separator_height = 1;
        padding = 10;
        horizontal_padding = 8;
        frame_width = 3;
        separator_color = "frame";
        sort = true;
        idle_threshold = 120;
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignement = "left";
        show_age_threshold = 60;
        word_wrap = true;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        icon_position = "left";
        max_icon_size = 50;
        sticky_history = true;
        history_length = 30;
        dmenu = "/usr/bin/env demenu -p dunst:";
        browser = "/usr/bin/env librewolf";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        force_xinerama = false;
      };
      experimental = {
        per_monitor_dpi = false;
      };
      urgency_low = {
        background = "#282828";
        foreground = "#928374";
        timeout = 5;
      };
      urgency_normal = {
        background = "#458588";
        foreground = "#ebdbb2";
        timeout = 5;
      };
      urgency_critical = {
        background = "#cc2421";
        foreground = "#ebdbb2";
        frame_color = "#fabd2f";
        timeout = 0;
      };
    };
  };
}
