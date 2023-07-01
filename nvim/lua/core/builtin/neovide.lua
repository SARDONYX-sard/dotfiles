-- https://neovide.dev/configuration.html
if vim.fn.exists(vim.g.neovide) == 1 then
  local M = {}
  M.default_font = 'CodeNewRoman NF:h13'

  vim.g.neovide_cursor_vfx_mode = 'railgun'
  vim.g.neovide_cursor_vfx_mode = 'wireframe'
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_transparency = 0.6
  vim.o.guifont = M.default_font

  ---@param size number
  function M.change_font_size(size)
    ---@type string|nil, string|nil
    local font_name, font_size = vim.o.guifont:match '^(.+):h(%d+)$'

    if font_name and font_size then
      local new_font_size = tonumber(font_size) + size
      local new_font_setting = font_name .. ':h' .. new_font_size
      vim.o.guifont = new_font_setting
    end
  end

  function M.increase_font_size()
    M.change_font_size(1)
  end

  function M.decrease_font_size()
    M.change_font_size(-1)
  end

  function M.reset_font()
    vim.o.guifont = M.default_font
  end

  vim.keymap.set('n', '<leader>0', M.reset_font, { desc = 'Font: reset', noremap = true })
  vim.keymap.set('n', '<leader>+', M.increase_font_size, { desc = 'Font: size +', noremap = true })
  vim.keymap.set('n', '<leader>-', M.decrease_font_size, { desc = 'Font: size -', noremap = true })
end
