-- Leader must be set before lazy loads
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('options')
require('keymaps')

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Colorscheme (gruvbox hard to match Zellij/WezTerm)
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup({ contrast = 'hard' })
      vim.o.background = 'dark'
      vim.cmd('colorscheme gruvbox')
    end,
  },

  -- Treesitter (parser installer only; highlighting via vim.treesitter below)
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.install').ensure_installed({
        'lua', 'go', 'javascript', 'typescript', 'tsx',
        'html', 'css', 'json', 'yaml', 'markdown',
      })
    end,
  },


  -- Git signs in gutter
  {
    'lewis6991/gitsigns.nvim',
    config = true,
  },

  -- Which-key
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = true,
  },
})

-- LSP (built-in since Neovim 0.11, no plugin needed)
vim.lsp.enable('gopls')
