local M = {}

M.plugins = {
  {
    -- Automagically follow symlinks
    --
    -- In the case of a symlinked init.lua file,
    -- install it in order to follow the link and edit it.
    'aymericbeaumet/vim-symlink',
    dependencies = { 'moll/vim-bbye' },
  },
}

return M
