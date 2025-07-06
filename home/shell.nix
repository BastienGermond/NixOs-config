{
  pkgs,
  lib,
  my,
  ...
}: let
  inherit (lib) mkOrder mkMerge;
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # enableSyntaxHighlighting = true;
    shellAliases = {
      gs = "git status";
      gaap = "git add -Ap";
      recommit = "git commit --cleanup=strip -e -F \"$(git rev-parse --git-dir)/COMMIT_EDITMSG\"";
    };

    initContent = mkMerge [
      # Last to run configuration
      (
        mkOrder 1500
        # zsh
        ''
          function hostname_color() {
            echo "$fg_bold[${my.color}]"
          }
          PROMPT=$(echo "$PROMPT" | sed "s/%{\$fg_bold\[blue\]%}%m%{\$reset_color%}/\$(hostname_color)%m%{\$reset_color%}/")
        ''
      )

      # General configuration
      (mkOrder 1000
        # zsh
        ''
          any-nix-shell zsh --info-right | source /dev/stdin
          export GPG_TTY=$(tty)
          export TIMER_FORMAT='[%d]'
          export TIMER_PRECISION=2

          transfer(){
            if [ $# -eq 0 ]; then
              echo "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>">&2;
              return 1;
            fi;

            if tty -s; then
              file="$1";
              file_name=$(basename "$file");
              if [ ! -e "$file" ]; then
                echo "$file: No such file or directory">&2;
                return 1;
              fi;
              if [ -d "$file" ]; then
                file_name="$file_name.zip",;
                (cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "https://t.germond.org/$file_name"|tee /dev/null,;
              else
              cat "$file"|curl --progress-bar --upload-file "-" "https://t.germond.org/$file_name"|tee /dev/null;
              fi;
            else
              file_name=$1;
              curl --progress-bar --upload-file "-" "https://t.germond.org/$file_name"|tee /dev/null;
            fi;
          }
        '')
    ];

    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.zsh-nix-shell;
      }
    ];

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "sudo" "timer"];
      theme = "re5et";
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
