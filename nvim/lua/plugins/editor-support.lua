local M = {}

M.plugins = {
  -- Editor Behavior
  {
    'rainbowhxch/accelerated-jk.nvim',
    lazy = true,
    event = 'VeryLazy',
    config = function()
      -- See: https://github.com/rainbowhxch/accelerated-jk.nvim#configuration
      require('accelerated-jk').setup {}
      vim.api.nvim_set_keymap('n', 'j', '<Plug>(accelerated_jk_gj)', {})
      vim.api.nvim_set_keymap('n', 'k', '<Plug>(accelerated_jk_gk)', {})
    end,
  },

  {
    -- A list of recently opened files is displayed.
    'goolord/alpha-nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('alpha.themes.startify').section.header.val = {} -- Remove logo
      require('alpha').setup(require('alpha.themes.startify').config)
      vim.keymap.set('n', '<leader>;', '<cmd>Alpha<CR>', { silent = true, desc = 'Show dashboard' })
    end,
  },

  {
    --Automatically opens the last project and jumps to the last changed point in the file.
    'Shatur/neovim-session-manager',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('session_manager').setup {}
    end,
  },

  {
    -- Change your working directory to the project root(.git) when you open a file.
    'notjedi/nvim-rooter.lua',
    config = function()
      require('nvim-rooter').setup()
    end,
  },

  {
    -- RELP Mode
    -- It displays the code results in real time (use cmd `:Codi`).
    'metakirby5/codi.vim',
    config = function()
      -- realtime code evaluate(REPL: Read-Eval-Print Loop). Maybe write each time.
      vim.keymap.set('n', '<leader>r', ':Codi<CR>', { silent = true, desc = '[r]ealtime code evaluate On/Off' })
    end,
  },

  -- Code time
  {
    -- calculate coding time(need wakatime account.)
    'wakatime/vim-wakatime',
  },

  -- Remote Development
  {
    -- Develop inside docker containers, just like VSCode, and parsing function of `devcontainer.json`.
    --
    --## Available Vim Commands(See: https://github.com/jamestthompson3/nvim-remote-containers/blob/master/README.md)

    -- - `AttachToContainer` wrapper for the `attachToContainer` lua function.
    -- - `BuildImage` wrapper for the `buildImage` lua function, takes "true" or "false" as an argument to decide whether or not to show the build progress in a floating window.
    -- - `StartImage` lists all available images and starts the one selected by you given the arguments found in the `devcontainer.json` file in your project's workspace.
    -- - `ComposeUp` wrapper for `composeUp` lua function.
    -- - `ComposeDown` wrapper for `composeDown` lua function.
    -- - `ComposeDestroy` wrapper for `composeDestroy` lua function.
    'jamestthompson3/nvim-remote-containers',
  },
}

return M
