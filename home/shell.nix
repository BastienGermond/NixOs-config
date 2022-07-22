{ config, pkgs, inputs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # enableSyntaxHighlighting = true;
    shellAliases = {
      gs = "git status";
    };

    initExtra = ''
      any-nix-shell zsh --info-right | source /dev/stdin
      export GPG_TTY=$(tty)
      export TIMER_FORMAT='[%d]'
      export TIMER_PRECISION=2
    '';

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "timer" ];
      theme = "re5et";
    };
  };
}
