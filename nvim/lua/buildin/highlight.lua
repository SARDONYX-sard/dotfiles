-- [[ Highlight on yank ]]
--
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local ok, wk = pcall(require, 'which-key')
if ok then
  wk.register {
    ['<leader>h'] = { name = '+highlight' },
  }
else
  vim.notify('Warn registing `highlight` prefix.', vim.log.levels.WARN, { title = 'buildin.highlight' })
end
vim.keymap.set('n', '<leader>hn', ':noh<CR>', { deec = 'No highlight words' }) -- reset highlight
