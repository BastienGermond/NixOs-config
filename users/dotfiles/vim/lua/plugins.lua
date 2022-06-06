-- Packer

local fn = vim.fn

vim.g.package_home = fn.stdpath("data") .. "/site/pack/packer/"

local plug_url_format = "https://hub.fastgit.xyz/%s"

-- Auto-install packer in case it hasn't been installed.
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.glob(install_path) == "" then
    vim.api.nvim_echo({ { "Installing packer.nvim in " .. install_path , "Type" } }, true, {})
    packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Load packer.nvim
vim.cmd("packadd packer.nvim")

-- PLUGINS

local util = require('packer.util')

require('packer').startup({
    function(use)
        use 'wbthomason/packer.nvim'

        use 'nvim-lua/plenary.nvim'

        use 'neovim/nvim-lspconfig'
        use 'ray-x/lsp_signature.nvim'

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

        -- Git
        use 'tpope/vim-fugitive'

        -- Highlight similar words
        use 'RRethy/vim-illuminate'

        -- Close quickfix or location list when attached buffer is closed
        use 'romainl/vim-qf'

        -- Fzf
        use 'junegunn/fzf'
        use 'junegunn/fzf.vim'

        use 'vim-scripts/DoxygenToolkit.vim'
        use 'stephpy/vim-yaml'
        use {
            'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate'
        }

        -- PostgreSQL syntax
        use 'lifepillar/pgsql.vim'

        -- Enable Neovim's builtin spellchecker for buffers with tree-sitter highlighting.
        use 'lewis6991/spellsitter.nvim'

        -- Nvim suggestion
        use 'hrsh7th/cmp-nvim-lsp'
        use 'hrsh7th/cmp-buffer'
        use 'hrsh7th/nvim-cmp'

        -- Language Tool
        use 'vigoux/LanguageTool.nvim'

        -- Go
        use {
            'fatih/vim-go',
            run = ':GoUpdateBinaries'
        }

        -- TypeScript
        use 'jose-elias-alvarez/null-ls.nvim'
        use 'jose-elias-alvarez/nvim-lsp-ts-utils'

        if packer_bootstrap then
            require('packer').sync()
        end
    end,
    config = {
        max_jobs = 16,
        compile_path = util.join_paths(vim.fn.stdpath('config'), 'lua', 'packer_compiled.lua'),
        git = {
            default_url_format = plug_url_format,
        },
    },
})

local status, _ = pcall(require, 'packer_compiled')
if not status then
    vim.notify("Error requiring packer_compiled.lua: run PackerSync to fix!")
end
