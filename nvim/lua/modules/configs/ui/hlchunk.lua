-- Show indent, space, color brackets &
-- Indentation display, showing bracket pair connections.
return function()
  local exclude_filetypes = {
    NvimTree = true,
    TelescopePrompt = true,
    [''] = true, -- because TelescopePrompt will set a empty ft, so add this.
    ['neo-tree'] = true,
    aerial = true,
    alpha = true,
    checkhealth = true,
    dashboard = true,
    help = true,
    lazy = true,
    lspinfo = true,
    lspsagafinder = true,
    man = true,
    mason = true,
    packer = true,
    plugin = true,
    toggleterm = true,
  }

  require('hlchunk').setup {
    chunk = {
      exclude_filetypes = exclude_filetypes,
      notify = false,
    },
    indent = {
      chars = { '┊' },
      exclude_filetypes = exclude_filetypes,
      notify = false,
    },
    line_num = {
      style = '#6b8f81', ---@type '#008080' | '#8b8f81' | '#6b8f81' - Candidate colors.
      notify = false,
    },
    blank = {
      chars = { '·' },
      exclude_filetypes = exclude_filetypes,
      style = {
        vim.api.nvim_get_hl(0, { name = 'Whitespace' }),
      },
      notify = false,
    },
    context = {
      enable = false,
      use_treesitter = false,
      chars = {
        '┃', -- Box Drawings Heavy Vertical
      },
      style = {
        { '#806d9c', '' },
      },
      exclude_filetypes = exclude_filetypes,
    },
  }
end
