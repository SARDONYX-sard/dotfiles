return function()
  vim.g.virtcolumn_char = '┊'
  vim.opt.colorcolumn = '100'
  vim.api.nvim_set_hl(0, 'VirtColumn', {
    -- - VScode ruler color '#979797'
    fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID 'Whitespace'), 'fg', 'gui'),
  })
end
