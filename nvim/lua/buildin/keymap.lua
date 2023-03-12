-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- swap ; and :
vim.keymap.set('n', ';', ':', { desc = 'command' })
vim.keymap.set('n', ':', ';', {})
vim.keymap.set('v', ';', ':', { desc = 'command' })
vim.keymap.set('v', ':', ';', {})

-- smooth j,k moving
vim.keymap.set('n', 'j', 'gj', { silent = true })
vim.keymap.set('n', 'gj', 'j', { silent = true })
vim.keymap.set('n', 'k', 'gk', { silent = true })
vim.keymap.set('n', 'gk', 'k', { silent = true })
vim.keymap.set('n', '$', 'g$', { silent = true })
vim.keymap.set('n', 'g$', '$', { silent = true })
vim.keymap.set('v', 'j', 'gj', { silent = true })
vim.keymap.set('v', 'gj', 'j', { silent = true })
vim.keymap.set('v', 'k', 'gk', { silent = true })
vim.keymap.set('v', 'gk', 'k', { silent = true })
vim.keymap.set('v', '$', 'g$', { silent = true })
vim.keymap.set('v', 'g$', '$', { silent = true })

-- vscode like keymap
vim.keymap.set('n', '<leader>q', ':q!<CR>', { silent = true, desc = 'Quit window(buffers)' })
vim.keymap.set('n', '<leader>w', ':w!<CR>', { silent = true, desc = 'Write file' })

-- mode changer
vim.keymap.set('i', 'jj', '<Esc>', { silent = true, desc = 'to Normal mode' })
vim.keymap.set('i', 'jk', '<Esc>', { silent = true, desc = 'to Normal mode' })
vim.keymap.set('i', 'kj', '<Esc>', { silent = true, desc = 'to Normal mode' })

-- - Move current line to up/down `Alt+j/k`
-- -Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { silent = true, desc = 'move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { silent = true, desc = 'move line up' })
vim.keymap.set('i', '<A-j>', '<Esc>:m .-2<CR>==', { silent = true, desc = 'move line down' })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==', { silent = true, desc = 'move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'move line down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'move line up' })

-- Yanks without line breaks to increase convenience.
vim.keymap.set('n', 'Y', 'y$', {})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open [d]iagnostic current line' })
vim.keymap.set('n', '<leader>D', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostics list' })

-- highlight keymaps
vim.keymap.set(
  'n',
  '<leader>h',
  ":execute(&hls && v:hlsearch ? 'noh' : 'set hls')<CR>",
  { silent = true, desc = 'Toggle [h]ighlight' }
)
