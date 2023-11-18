-- swap ; and :
vim.keymap.set('n', ';', ':', { desc = 'command' })
vim.keymap.set('n', ':', ';', {})
vim.keymap.set('v', ';', ':', { desc = 'command' })
vim.keymap.set('v', ':', ';', {})

-- See: https://github.com/vscode-neovim/vscode-neovim/issues/121#issuecomment-1505164619
if vim.g.vscode then
  vim.api.nvim_set_keymap('x', 'gc', '<Plug>VSCodeCommentary', {})
  vim.api.nvim_set_keymap('n', 'gc', '<Plug>VSCodeCommentary', {})
  vim.api.nvim_set_keymap('o', 'gc', '<Plug>VSCodeCommentary', {})
  vim.api.nvim_set_keymap('n', 'gcc', '<Plug>VSCodeCommentaryLine', {})
  vim.api.nvim_set_keymap('n', '<D-/>', 'gcc', {})
  vim.api.nvim_set_keymap('x', '<D-/>', 'gc', {})
else
  --The same keymaps I`m setting up in VSCode Vim
  vim.keymap.set('n', '<leader>q', ':q!<CR>', { silent = true, desc = 'Quit window(buffers)' })
  vim.keymap.set('n', '<leader>w', ':w!<CR>', { silent = true, desc = 'Write file' })

  -- Move current line to up/down `Alt+j/k` like VSCode
  -- - Ref: https://vim.fandom.com/wiki/Moving_lines_up_or_down
  vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { silent = true, desc = 'Move line down' })
  vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { silent = true, desc = 'Move line up' })
  vim.keymap.set('i', '<A-j>', '<Esc>:m .-2<CR>==', { silent = true, desc = 'Move line down' })
  vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==', { silent = true, desc = 'Move line up' })
  vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move line down' })
  vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move line up' })

  -- Highlight keymaps
  --
  -- quote string references
  -- `:help :put`
  -- See: https://stackoverflow.com/questions/24164365/vimscript-quotes-in-strings-when-used-as-expressions
  vim.keymap.set(
    'n',
    '<leader>H',
    ":execute(&hls && v:hlsearch ? 'noh|echo ''Highlight: Off'' ' : 'set hls|echo ''Highlight: On'' ')<CR>",
    { silent = true, desc = 'Toggle [H]ighlight' }
  )

  -- buffer
  --See: https://stackoverflow.com/questions/4545275/vim-close-all-buffers-but-this-one
  -- vim.keymap.set('n', '<space>bl', ':%bd|e#|bd#<CR>', { silent = true, desc = 'Buffer: delete others' })
  -- vim.keymap.set('n', '<space>c', ':bdelete<CR>', { silent = true, desc = 'Buffer: [c]lose' })
end
