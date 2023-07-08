{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      debug.log_level = "INFO";
      font = {
        size = 7.5;
        normal = {
          family = "JuliaMono";
        };
        bold = {
          family = "JuliaMono";
        };
        italic = {
          family = "JuliaMono";
        };
        bold_italic = {
          family = "JuliaMono";
        };
      };
      shell.program = "/usr/bin/env";
      shell.args = ["zsh"];
      key_bindings = [
        {
          key = "Return";
          mods = "Control|Shift";
          action = "SpawnNewInstance";
        }
      ];
    };
  };
}
