{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = false;
    package = pkgs.neovim; # pkgs.neovim-nightly;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
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
      (nvim-treesitter.withPlugins (p: [p.c p.python p.latex p.nix p.go]))
    ];

    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ../dotfiles/vimrc)
    ];
  };
}
