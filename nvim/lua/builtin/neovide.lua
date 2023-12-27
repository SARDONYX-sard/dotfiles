if vim.fn.exists(vim.g.neovide) == 1 then
  local M = {}
  M.default_font = 'CodeNewRoman NF:h13'

  vim.api.nvim_set_option_value('guifont', M.default_font, {})
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_trail_length = 0.05
  vim.g.neovide_cursor_vfx_mode = 'railgun'
  vim.g.neovide_cursor_vfx_mode = 'wireframe'
  vim.g.neovide_cursor_vfx_opacity = 200.0
  vim.g.neovide_cursor_vfx_particle_density = 5.0
  vim.g.neovide_cursor_vfx_particle_lifetime = 1.2
  vim.g.neovide_cursor_vfx_particle_speed = 20.0
  vim.g.neovide_no_idle = true
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_transparency = 0.6

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
