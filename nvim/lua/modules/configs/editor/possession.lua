local M = {}

--- Load session automatically .

---Get `.git` directory.
---@return string | nil
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
---@param event_name string |nil - default: 'VimLeave'
function M.enable_save_on(event_name)
  vim.api.nvim_create_autocmd({ event_name or 'VimLeave' }, {
    pattern = '*',
    callback = function()
      local cur_buf_abs_path = vim.fn.expand '%:p'
      if type(cur_buf_abs_path) ~= 'table' and is_tmp_file(cur_buf_abs_path) == false then
        M.save_with_leaf_dir()
      end
    end,
    nested = false,
  })
end

--- Load session automatically .
function M.enable_autoload()
  vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    pattern = '*',
    callback = function()
      pcall(vim.fn.execute, 'PossessionLoad')
    end,
    nested = true,
  })
end

return function()
  -- https: //github.com/jedrzejboczar/possession.nvim#configuration
  require('possession').setup {
    load_silent = false,
    autosave = {
      on_load = false,
      on_quit = false,
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
        preserve_layout = true,
        match = {
          floating = true,
          custom = false,
        },
      },
      dapui = false,
      delete_buffers = true,
    },
  }

  M.enable_save_on()
  if vim.fn.argc() <= 0 then
    vim.fn.execute 'PossessionLoad'
  end

  -- For PossessionSave keymap
  vim.g.save_with_leaf_dir = M.save_with_leaf_dir
end
