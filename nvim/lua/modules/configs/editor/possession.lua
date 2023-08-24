local M = {}

--- Load session automatically .
function M.enable_autoload()
  vim.api.nvim_create_autocmd('VimEnter', {
    pattern = '*',
    callback = function()
      pcall(vim.fn.execute, 'PossessionLoad')
    end,
    nested = true,
  })
end

---Get `.git` directory.
---@return string|nil
local function get_git_dir()
  -- Run git command to get the root directory
  local git_root_cmd = io.popen 'git rev-parse --show-toplevel'
  if git_root_cmd == nil then
    return nil
  end
  -- Read a line from the output of the subprocess created by `io.popen`.
  local git_root_dir = git_root_cmd:read '*line'
  git_root_cmd:close()

  return git_root_dir
end

function M.save_with_leaf_dir()
  local cwd = get_git_dir() or vim.fn.getcwd()
  local leaf_dir = vim.fn.fnamemodify(cwd, ':t')

  local no_confirm_opt = '!'
  if leaf_dir == '' then
    vim.fn.execute('PossessionSave' .. no_confirm_opt)
  else
    vim.fn.execute('PossessionSave' .. no_confirm_opt .. leaf_dir)
  end
end

---@param path string
---@return boolean
local function is_tmp_file(path)
  local tmp_patterns = { 'tmp', 'temp' }
  for _, pattern in ipairs(tmp_patterns) do
    if string.find(string.lower(path), pattern) then
      return true
    end
  end
  return false
end

--- Auto save sessions for non-temp files.
--- Handwritten session save events
--- (since the default session save does not seem to be able to save sessions specific to each project)
---@param event_name string|nil - default: 'VimLeave'
function M.enable_save_on(event_name)
  vim.api.nvim_create_autocmd(event_name or 'VimLeave', {
    pattern = '*',
    callback = function()
      local cur_buf_abs_path = vim.fn.expand '%:p'
      if is_tmp_file(cur_buf_abs_path) == false then
        M.save_with_leaf_dir()
      end
    end,
    nested = false,
  })
end

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
      on_load = false,
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
        preserve_layout = true, -- or fun(win): boolean
        match = {
          floating = true,
          custom = false, -- or fun(win): boolean
        },
      },
      delete_buffers = true,
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

  --- Do not want session to load if a file path, etc., is passed as an argument.
  --- # Example
  --- $nvim.exe -p --embed <path> => argv = [nil, 'nvim.exe', '-p', '--embed', <path>]
  --- @return boolean
  local contain_path_in_arg = function()
    return (vim.fn.filereadable(vim.v.argv[3]) == 1) or (vim.fn.filereadable(vim.v.argv[4]) == 1)
  end

  if not contain_path_in_arg() then
    M.enable_autoload()
  end
  M.enable_save_on()

  vim.keymap.set('n', '<leader>sc', ':PossessionClose<CR>', { silent = true, desc = 'Session: Close' })
  vim.keymap.set('n', '<leader>sd', ':PossessionDelete<CR>', { silent = true, desc = 'Session: Delete' })
  vim.keymap.set('n', '<leader>sl', ':Telescope possession list<CR>', { silent = true, desc = 'Session: List' })
  vim.keymap.set('n', '<leader>sr', ':PossessionLoad<CR>', { silent = true, desc = 'Session: Restore' })
  vim.keymap.set('n', '<leader>ss', M.save_with_leaf_dir, { silent = true, desc = 'Session: Save' })
end
