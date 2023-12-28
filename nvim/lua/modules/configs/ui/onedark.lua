-- e.g. vim.cmd.colorscheme 'onedark'
return function()
  -- https://github.com/navarasu/onedark.nvim
  require('onedark').setup {
    style = 'darker', ---@type 'dark'|'darker'|'cool'|'deep'|'warm'|'warmer'|'light' Default theme style.
    transparent = false, -- Show/hide background
    -- Lualine options --
    lualine = {
      transparent = true, -- lualine center bar transparency
    },
    diagnostics = {
      darker = true, -- darker colors for diagnostic
      undercurl = true, -- use undercurl instead of underline for diagnostics
      background = false, -- use background color for virtual text
    },
  }

  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    desc = 'Force background transparency',
    callback = function()
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none', fg = '#5E81AC' })
    end,
  })
end
