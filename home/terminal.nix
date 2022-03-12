{config, pkgs, inputs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font.size = 8.0;
      debug.log_level = "INFO";
      shell.program = "/usr/bin/env";
      shell.args = [ "zsh" ];
    };
  };
}
