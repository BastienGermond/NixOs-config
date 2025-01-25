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
        auto-pairs = {
          "{" = "}";
        };
        inline-diagnostics = {
          cursor-line = "warning";
          other-lines = "error";
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
        pylsp = {
          command = "${pkgs.python311Packages.python-lsp-server}/bin/pylsp";
          config.pylsp = {
            "plugins.pylsp_mypy.enabled" = true;
            "plugins.pylsp_mypy.live_mode" = true;
          };
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
          workspace-lsp-roots = [".clangd" "compile_commands.json"];
          roots = ["compile_commands.json"];
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
        # {name = "rust";}
        {name = "tfvars";}
        {name = "hcl";}
        {
          name = "rst";
          scope = "source.rst";
          file-types = ["rst"];
          language-servers = ["ltex-ls"];
        }
        {
          name = "markdown";
          language-servers = ["ltex-ls"];
        }
        {name = "git-commit";}
        # {
        #   name = "python";
        #   language-servers = ["pylsp"];
        # }
        {
          name = "typst";
          formatter = {
            command = "typstfmt";
            args = ["--output" "-"];
          };
          auto-format = true;
        }
      ];
    };
  };

  home.sessionVariables.EDITOR = "hx";
}
