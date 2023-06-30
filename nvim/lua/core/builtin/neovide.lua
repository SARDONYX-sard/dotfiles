-- https://neovide.dev/configuration.html
if vim.fn.exists(vim.g.neovide) == 1 then
  vim.g.neovide_cursor_vfx_mode = 'railgun'
  vim.g.neovide_cursor_vfx_mode = 'wireframe'
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_transparency = 0.6

  local font_settings = 'Cascadia Code:h13'
  vim.o.guifont = font_settings

  local M = {}

  ---@param size number
  function M.change_font_size(size)
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
    vim.o.guifont = font_settings
  end

  vim.keymap.set('n', '<leader>0', M.reset_font, { desc = 'Font: reset', noremap = true })
  vim.keymap.set('n', '<leader>+', M.increase_font_size, { desc = 'Font: size +', noremap = true })
  vim.keymap.set('n', '<leader>-', M.decrease_font_size, { desc = 'Font: size -', noremap = true })
end
