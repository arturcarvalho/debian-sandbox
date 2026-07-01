-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- No swap, persistent undo
vim.opt.swapfile = false
vim.opt.undofile = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Clipboard over SSH via OSC 52
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
vim.opt.clipboard = 'unnamedplus'

-- Treesitter highlighting via built-in API
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'go', 'javascript', 'typescript', 'tsx', 'html', 'css', 'json', 'yaml', 'markdown' },
  callback = function() vim.treesitter.start() end,
})
