-- Packer
vim.g.package_home = fn.stdpath("data") .. "/site/pack/packer/"
local packer_install_dir = vim.g.package_home .. "/opt/packer.nvim"

local plug_url_format = ""
if vim.g.is_linux then
    plug_url_format = "https://hub.fastgit.xyz/%s"
else
    plug_url_format = "https://github.com/%s"
end

local packer_repo = string.format(plug_url_format, "wbthomason/packer.nvim")
local install_cmd = string.format("10split |term git clone --depth=1 %s %s", packer_repo, packer_install_dir)

-- Auto-install packer in case it hasn't been installed.
if fn.glob(packer_install_dir) == "" then
    vim.api.nvim_echo({ { "Installing packer.nvim", "Type" } }, true, {})
    vim.cmd(install_cmd)
end

-- Load packer.nvim
vim.cmd("packadd packer.nvim")

-- PLUGINS

return require('packer').startup(function()
    use 'nvim-lua/plenary.nvim'

    use 'neovim/nvim-lspconfig'
    use 'ray-x/lsp_signature.nvim'

    use 'williamboman/nvim-lsp-installer'
    use 'L3MON4D3/LuaSnip'

    use 'ludovicchabant/vim-gutentags'
    use 'vim-airline/vim-airline'
    use 'vim-python/python-syntax'
    use 'rust-lang/rust.vim'
    use 'junegunn/vim-easy-align'
    use 'rhysd/vim-clang-format'
    use 'kergoth/vim-bitbake'
    use 'ftan84/vim-khaled-ipsum'

    use 'alpertuna/vim-header'

    -- Highlight similar words
    use 'RRethy/vim-illuminate'

    -- Close quickfix or location list when attached buffer is closed
    use 'romainl/vim-qf'

    -- Fzf
    use 'junegunn/fzf'
    use 'junegunn/fzf.vim'

    use 'tpope/vim-fugitive'
    use 'vim-scripts/DoxygenToolkit.vim'
    use 'stephpy/vim-yaml'
    use 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    use 'lewis6991/spellsitter.nvim'

    -- Nvim suggestion
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/nvim-cmp'

    use 'vim-scripts/DoxygenToolkit.vim'

    -- File explorer
    use 'kyazdani42/nvim-web-devicons' -- for file icons
    use 'kyazdani42/nvim-tree.lua'

    -- Language Tool
    use 'vigoux/LanguageTool.nvim'

    -- Go
    use 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

    -- TypeScript
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'jose-elias-alvarez/nvim-lsp-ts-utils'
end)
