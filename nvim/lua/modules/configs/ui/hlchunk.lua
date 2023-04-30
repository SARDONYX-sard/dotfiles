-- Show indent, space, color brackets &
-- Indentation display, showing bracket pair connections.
return function()
  local exclude_filetype = {
    alpha = true,
    aerial = true,
    dashboard = true,
    help = true,
    lspinfo = true,
    packer = true,
    checkhealth = true,
    man = true,
    mason = true,
    NvimTree = true,
    ['neo-tree'] = true,
    plugin = true,
    lazy = true,
    TelescopePrompt = true,
    [''] = true, -- because TelescopePrompt will set a empty ft, so add this.
  }

  require('hlchunk').setup {
    chunk = {
      style = '#BB0000',
    },
    indent = {
      chars = { '┊' },
      exclude_filetype = exclude_filetype,
    },
    line_num = {
      style = '#6b8f81', ---@type '#008080'|'#8b8f81'|'#6b8f81' - Candidate colors.
    },
    blank = {
      chars = { '·' },
      exclude_filetype = exclude_filetype,
      style = {
        vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID 'Whitespace'), 'fg', 'gui'),
      },
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
      exclude_filetype = exclude_filetype,
    },
  }
end
