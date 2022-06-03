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
    '';

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.4.0";
          sha256 = "037wz9fqmx0ngcwl9az55fgkipb745rymznxnssr3rx9irb6apzg";
        };
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "re5et";
    };
  };
}
