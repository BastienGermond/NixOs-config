{ config, pkgs, lib, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
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
      gopls
      nodePackages.typescript-language-server
      nodePackages.prettier
      nodePackages.eslint
    ];

    plugins = with pkgs.vimPlugins; [
      vim-plug
      vim-which-key
      vim-nix
      suda-vim
    ];

    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ../users/dotfiles/vimrc)
    ];
  };
}
