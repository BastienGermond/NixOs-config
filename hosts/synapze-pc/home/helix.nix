{
  config,
  pkgs,
  ...
}: {
  programs.helix = {
    enable = true;
    package = pkgs.helix;
    settings = {
      theme = "everforest_dark";
      editor = {
        line-number = "absolute";
        mouse = false;
        cursorline = true;
        auto-format = true;
        text-width = 100;
        soft-wrap = {
          enable = false;
          wrap-at-text-width = true;
        };
        smart-tab = {
          enable = false;
        };
        statusline = {
          right = ["diagnostics" "selections" "register" "position-percentage" "position" "file-encoding"];
        };
      };
    };
    languages = {
      language-server = {
        ltex-ls = {
          command = "${pkgs.ltex-ls}/bin/ltex-ls";
        };
        nixd = {
          command = "${pkgs.nixd}/bin/nixd";
        };
      };
      language = [
        {
          name = "c";
          auto-format = true;
          text-width = 100;
          formatter = {
            command = "clang-format";
          };
        }
        {name = "cpp";}
        {
          name = "nix";
          language-servers = ["nixd"];
          formatter = {
            command = "${pkgs.alejandra}/bin/alejandra";
          };
        }
        {name = "tsx";}
        {name = "go";}
        {
          name = "cmake";
          language-servers = ["cmake-language-server"];
          formatter = {
            command = "${pkgs.cmake-format}/bin/cmake-format";
          };
        }
        {name = "comment";}
        {
          name = "latex";
          scope = "text.tex";
          file-types = ["tex"];
          language-servers = ["ltex-ls" "texlab"];
        }
        {name = "rust";}
      ];
    };
  };
}
