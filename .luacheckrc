---@diagnostic disable: lowercase-global, undefined-global
-- luacheck: globals, ignore 111 112

-- ref
-- - https://luacheck.readthedocs.io/en/stable/inline.html
-- - https://github.com/neovim/neovim/blob/master/.luacheckrc

-- vim: ft=lua tw=80
stds.nvim = {
  read_globals = { 'jit' },
}
std = 'lua51+nvim'

-- Ignore W211 (unused variable) with preload files.
files['**/preload.lua'] = { ignore = { '211' } }
-- Allow vim module to modify itself, but only here.

-- Don't report unused self arguments of methods.
self = false

-- Rerun tests only if their modification time changed.
cache = true

ignore = {
  -- "111",     -- setting non-standard global variable 'ignore'
  -- "112",     -- mutating non-standard global variable 'files'
  '121', -- setting read-only global variable 'vim'
  '122', -- setting read-only field of global variable 'vim'
  '212/_.*', -- unused argument, for vars with "_" prefix
  '631', -- max_line_length
}

-- Global objects defined by the C code
read_globals = {
  'vim',
}

globals = {
  'vim.g',
  'vim.b',
  'vim.w',
  'vim.o',
  'vim.bo',
  'vim.wo',
  'vim.go',
  'vim.env',
}

exclude_files = {}
