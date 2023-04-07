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

-- Highlight(Show) White space.
-- https://gist.github.com/kawarimidoll/ed105a754f3d64f9f174d2c4c43c0a6a#file-highlight_extra_whitespaces-vim
vim.cmd [[ autocmd VimEnter * ++once
      \ call matchadd('ExtraWhitespace', "[\u00A0\u2000-\u200B\u3000]")
      \ | highlight default ExtraWhitespace  ctermbg=239 guibg=none
]]

-- local set_hl_for_floating_window = function()
--   vim.api.nvim_set_hl(0, 'NormalFloat', {
--     link = 'Normal',
--   })
--   vim.api.nvim_set_hl(0, 'FloatBorder', {
--     bg = 'none',
--   })
-- end
--
-- set_hl_for_floating_window()
--
-- vim.api.nvim_create_autocmd('ColorScheme', {
--   pattern = '*',
--   desc = 'Avoid overwritten by loading color schemes later',
--   callback = set_hl_for_floating_window,
-- })
