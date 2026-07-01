local map = function(keys, action, desc)
  vim.keymap.set('n', keys, action, { desc = desc })
end

-- Clear search highlight
map('<Esc>', '<cmd>nohlsearch<CR>', 'Clear search highlight')

-- Save
map('<leader>w', '<cmd>write<CR>', 'Save file')

-- Split navigation
map('<C-h>', '<C-w>h', 'Move to left split')
map('<C-j>', '<C-w>j', 'Move to down split')
map('<C-k>', '<C-w>k', 'Move to up split')
map('<C-l>', '<C-w>l', 'Move to right split')
