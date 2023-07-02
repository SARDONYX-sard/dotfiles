return function()
  -- https://github.com/jedrzejboczar/possession.nvim#configuration
  require('possession').setup {
    silent = false,
    load_silent = true,
    debug = false,
    logfile = false,
    prompt_no_cr = false,
    autosave = {
      current = true, -- or fun(name): boolean
      tmp = false, -- or fun(): boolean
      tmp_name = 'tmp', -- or fun(): string
      on_load = true,
      on_quit = true,
    },
    commands = {
      save = 'PossessionSave',
      load = 'PossessionLoad',
      rename = 'PossessionRename',
      close = 'PossessionClose',
      delete = 'PossessionDelete',
      show = 'PossessionShow',
      list = 'PossessionList',
      migrate = 'PossessionMigrate',
    },
    plugins = {
      close_windows = {
        hooks = { 'before_save', 'before_load' },
        preserve_layout = true, -- or fun(win): boolean
        match = {
          floating = true,
          custom = false, -- or fun(win): boolean
        },
      },
      delete_buffers = false,
    },
    telescope = {
      list = {
        default_action = 'load',
        mappings = {
          save = { n = '<c-x>', i = '<c-x>' },
          load = { n = '<c-v>', i = '<c-v>' },
          delete = { n = '<c-t>', i = '<c-t>' },
          rename = { n = '<c-r>', i = '<c-r>' },
        },
      },
    },
  }

  local function save_with_leaf_dir()
    local leaf_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

    if leaf_dir ~= '' then
      vim.fn.execute('PossessionSave ' .. leaf_dir)
    else
      vim.fn.execute 'PossessionSave'
    end
  end

  --- If this is not enabled, tree-sitter and lsp will not be enabled the first time. 2 reloads will occur.
  local function enable_autoload()
    vim.api.nvim_create_autocmd('VimEnter', {
      pattern = '*',
      callback = function()
        pcall(vim.fn.execute, 'PossessionLoad')
      end,
      nested = true,
    })
  end

  enable_autoload()
  vim.keymap.set('n', '<leader>sc', ':PossessionClose<CR>', { silent = true, desc = 'Session: Close' })
  vim.keymap.set('n', '<leader>sd', ':PossessionDelete<CR>', { silent = true, desc = 'Session: Delete' })
  vim.keymap.set('n', '<leader>sl', ':Telescope possession list<CR>', { silent = true, desc = 'Session: List' })
  vim.keymap.set('n', '<leader>sr', ':PossessionLoad<CR>', { silent = true, desc = 'Session: Restore' })
  vim.keymap.set('n', '<leader>ss', save_with_leaf_dir, { silent = true, desc = 'Session: Save' })
end
