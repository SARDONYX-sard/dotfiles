-- swap ; and :
vim.keymap.set('n', ';', ':', { desc = 'command' })
vim.keymap.set('n', ':', ';', {})
vim.keymap.set('v', ';', ':', { desc = 'command' })
vim.keymap.set('v', ':', ';', {})

--The same keymaps I`m setting up in VSCode Vim
vim.keymap.set('n', '<leader>q', ':q!<CR>', { silent = true, desc = 'Quit window(buffers)' })
vim.keymap.set('n', '<leader>w', ':w!<CR>', { silent = true, desc = 'Write file' })

-- Move current line to up/down `Alt+j/k` like VSCode
-- - Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { silent = true, desc = 'move line down' })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { silent = true, desc = 'move line up' })
vim.keymap.set('i', '<A-j>', '<Esc>:m .-2<CR>==', { silent = true, desc = 'move line down' })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==', { silent = true, desc = 'move line up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'move line down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'move line up' })

-- Highlight keymaps
--
-- quote string refferences
-- `:help :put`
-- See: https://stackoverflow.com/questions/24164365/vimscript-quotes-in-strings-when-used-as-expressions
vim.keymap.set(
  'n',
  '<leader>h',
  ":execute(&hls && v:hlsearch ? 'noh|echo ''Highlight: Off'' ' : 'set hls|echo ''Highlight: On'' ')<CR>",
  { silent = true, desc = 'Toggle [h]ighlight' }
)

-- General buffer keymaps
-- vim.keymap.set('n', '<space>c', ':bdelete<CR>', { silent = true, desc = 'Buffer: [c]lose' })

--See: https://stackoverflow.com/questions/4545275/vim-close-all-buffers-but-this-one
-- vim.keymap.set('n', '<space>bl', ':%bd|e#|bd#<CR>', { silent = true, desc = 'Buffer: [l]ast only ' })

-- plugins
vim.keymap.set('n', '<leader>;', '<cmd>Alpha<CR>', { silent = true, desc = 'Show dashboard' })
vim.keymap.set('n', '<space>c', ':bd<CR>', { silent = true, desc = 'Buffer: [c]lose' })
vim.keymap.set('n', '<space>bl', ':BufDelOthers<CR>', { silent = true, desc = 'Buffer: de[l]ete others' })
