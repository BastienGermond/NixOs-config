{ config, pkgs, lib, ... }:

let
  gopls_0_8_1 = pkgs.buildGo118Module rec {
    inherit (pkgs.gopls.drvAttrs) pname doCheck buildPhase installPhase modRoot subPackages;

    inherit (pkgs.gopls) meta;

    version = "0.8.1";

    src = pkgs.fetchFromGitHub {
      owner = "golang";
      repo = "tools";
      rev = "gopls/v0.8.1"; # "gopls/v${version}";
      sha256 = "sha256-ypuZQt6iF1QRk/FsoTKnJlb5CWIEkvK7r37t4rSxhmU=";
    };

    vendorSha256 = "sha256-SY08322wuJl8F790oXGmYo82Yadi14kDpoVGCGVMF0c="; # "sha256-CjUF4NqiT3BU+pybDKKNaye//HOGVOGRJOeoYKkF6i0=";
  };
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim; # pkgs.neovim-nightly;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      tree-sitter
      ctags

      # Fzf
      fzf

      # LSP
      pyright
      rnix-lsp
      ccls
      texlab
      gopls_0_8_1
      nodePackages.typescript-language-server
      nodePackages.prettier
      nodePackages.eslint
      rust-analyzer
      clippy
      ltex-ls
      nil
    ];

    plugins = with pkgs.vimPlugins; [
      vim-packer
      vim-which-key
      vim-nix
      suda-vim
    ];

    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ../dotfiles/vimrc)
    ];
  };

  home.sessionVariables.EDITOR = "nvim";
}
