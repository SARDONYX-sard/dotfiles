-- Show indent, space, color brackets &
-- Indentation display, showing bracket pair connections.
return function()
  local exclude_filetype = {
    alpha = true,
  }

  require('hlchunk').setup {
    chunk = {
      enable = true,
      style = '#BB0000',
    },
    indent = {
      enable = true,
      chars = { '┊' },
      exclude_filetype = exclude_filetype,
    },
    line_num = {
      enable = true,
      style = '#6b8f81', ---@type '#008080'|'#8b8f81'|'#6b8f81' - Candidate colors.
    },
    blank = {
      enable = true,
      chars = { '·' },
      exclude_filetype = exclude_filetype,
      style = {
        vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID 'Whitespace'), 'fg', 'gui'),
      },
    },
  }
end
