return function()
  require('onedark').setup {
    style = 'dark', ---@type 'dark'|'darker'|'cool'|'deep'|'warm'|'warmer'|'light' Default theme style.
    transparent = true, -- Show/hide background
    -- Lualine options --
    lualine = {
      transparent = true, -- lualine center bar transparency
    },
  }
  -- vim.cmd.colorscheme 'onedark'
end
