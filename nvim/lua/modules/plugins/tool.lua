local tool = {}

tool['tpope/vim-fugitive'] = {
  lazy = true,
  cmd = { 'Git', 'G' },
}
-- only for fcitx5 user who uses non-English language during coding
-- tool["pysan3/fcitx5.nvim"] = {
-- 	lazy = true,
-- 	event = "BufReadPost",
-- 	cond = vim.fn.executable("fcitx5-remote") == 1,
-- 	config = require("tool.fcitx5"),
-- }
tool['nvim-tree/nvim-tree.lua'] = {
  lazy = true,
  cmd = {
    'NvimTreeToggle',
    'NvimTreeOpen',
    'NvimTreeFindFile',
    'NvimTreeFindFileToggle',
    'NvimTreeRefresh',
  },
  event = 'BufEnter',
  config = require 'tool.nvim-tree',
}
tool['aymericbeaumet/vim-symlink'] = {
  -- Automatically follow symlinks
  --
  -- In the case of a symlinked init.lua file,
  -- install it in order to follow the link and edit it.
  -- lazy = true,
  event = 'BufEnter',
  dependencies = { 'moll/vim-bbye' },
}
tool['ibhagwan/smartyank.nvim'] = {
  lazy = true,
  event = 'BufReadPost',
  config = require 'tool.smartyank',
}

if vim.fn.executable 'bash' and (vim.fn.has 'linux' == 1 or vim.fn.has 'mac' == 1) then
  tool['michaelb/sniprun'] = {
    lazy = true,
    -- You need to cd to `~/.local/share/nvim/site/lazy/sniprun/` and execute `bash ./install.sh`,
    -- if you encountered error about no executable sniprun found.
    build = 'bash ./install.sh',
    cmd = { 'SnipRun' },
    config = require 'tool.sniprun',
  }
end

tool['akinsho/toggleterm.nvim'] = {
  lazy = true,
  cmd = {
    'ToggleTerm',
    'ToggleTermSetName',
    'ToggleTermToggleAll',
    'ToggleTermSendVisualLines',
    'ToggleTermSendCurrentLine',
    'ToggleTermSendVisualSelection',
  },
  config = require 'tool.toggleterm',
}
tool['folke/trouble.nvim'] = {
  lazy = true,
  cmd = { 'Trouble', 'TroubleToggle', 'TroubleRefresh' },
  config = require 'tool.trouble',
}
tool['folke/which-key.nvim'] = {
  lazy = true,
  event = { 'CursorHold', 'CursorHoldI' },
  config = require 'tool.which-key',
}
tool['gelguy/wilder.nvim'] = {
  lazy = true,
  event = 'CmdlineEnter',
  config = require 'tool.wilder',
  dependencies = { 'romgrk/fzy-lua-native' },
}

----------------------------------------------------------------------
--                        Telescope Plugins                         --
----------------------------------------------------------------------
tool['nvim-telescope/telescope.nvim'] = {
  lazy = true,
  cmd = 'Telescope',
  config = require 'tool.telescope',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons' },
    { 'nvim-lua/plenary.nvim' },
    { 'debugloop/telescope-undo.nvim' },
    {
      'ahmedkhalf/project.nvim',
      event = 'BufReadPost',
      config = require 'tool.project',
    },
    {
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      'nvim-telescope/telescope-fzf-native.nvim',
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = (function()
        if vim.fn.has 'win32' == 1 then
          return 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        elseif vim.fn.has 'unix' == 1 then
          return 'make'
        end
      end)(),
      cond = function()
        if vim.fn.has 'win32' then
          return vim.fn.executable 'cmake' == 1 and vim.fn.executable 'cl.exe' == 1
        elseif vim.fn.has 'unix' then
          return vim.fn.executable 'make' == 1 and (vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1)
        end
      end,
    },
    { 'nvim-telescope/telescope-frecency.nvim', dependencies = {
      { 'kkharji/sqlite.lua' },
    } },
    { 'jvgrootveld/telescope-zoxide' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
  },
}

----------------------------------------------------------------------
--                           DAP Plugins                            --
----------------------------------------------------------------------
tool['mfussenegger/nvim-dap'] = {
  lazy = true,
  cmd = {
    'DapSetLogLevel',
    'DapShowLog',
    'DapContinue',
    'DapToggleBreakpoint',
    'DapToggleRepl',
    'DapStepOver',
    'DapStepInto',
    'DapStepOut',
    'DapTerminate',
  },
  config = require 'tool.dap',
  dependencies = {
    {
      'rcarriga/nvim-dap-ui',
      config = require 'tool.dap.dapui',
    },
  },
}

return tool
