local M = {}

M.plugins = {
  -- Editor Behavior
  --
  {
    -- Auto jump at your last edit position when reopen files.
    'ethanholz/nvim-lastplace',
    config = function()
      require('nvim-lastplace').setup {}
    end,
  },

  {
    -- A list of recently opened files is displayed.
    'goolord/alpha-nvim',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      require('alpha').setup(require('alpha.themes.startify').config)
      vim.keymap.set('n', '<leader>;', '<cmd>Alpha<CR>', { silent = true, desc = 'Show dashboard' })
    end,
    opts = {
      -- but it will prevent the FileType autocmd from firing, which may break integration with other plguins.
      noautocmd = true, ---@type boolean - default: false (disabled)
    },
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
