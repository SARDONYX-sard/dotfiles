if not vim.g.vscode then
  -- NOTE: Always load these keymaps first to make it easier to correct and edit plugin settings in case of errors.
  vim.keymap.set('n', '<space>v', function()
    -- I'm clenching errors in pcall to prevent buff errors in `editorconfig.nvim`.
    pcall(vim.cmd.edit, debug.getinfo(1, 'S').short_src)
  end, { desc = '[v]iew & edit init.lua' })
  require 'core'
end
