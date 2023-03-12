-- Git related plugins
local M = {}

M.plugins = {
  {
    'tpope/vim-fugitive',
    config = function()
      pcall(require('which-key').register, {
        ['<leader>g'] = {
          name = '+Git',
        },
      })
    end,
  },

  { 'tpope/vim-rhubarb' },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        -- signs = {
        --   add = { text = '+' },
        --   change = { text = '~' },
        --   delete = { text = '_' },
        --   topdelete = { text = '‾' },
        --   changedelete = { text = '~' },
        -- },
      }
    end,
  },
}

---Normal mode keymaps creator function.
---@param keys string
---@param func function|string
---@param desc string
local nmap = function(keys, func, desc)
  if desc then
    desc = 'Git: ' .. desc
  end
  vim.keymap.set('n', keys, func, { noremap = true, silent = true, desc = desc })
end

--commit keymaps
nmap('<leader>gc', ':<C-u>Git commit<CR>', '[c]ommit')
nmap('<leader>gC', ':<C-u>Git commit --amend<CR>', 'modify prev [C]ommit msg')

-- In WSL, if GPG_TTY is not set as in `export GPG_TTY=$(tty)`, the prompt will not appear and the prominent commit will fail.
-- Therefore, currently the only way to do a prominent commit is to do it manually with a command.
if not (os.getenv 'WSL_INTEROP' and os.getenv 'WSL_DISTRO_NAME') then
  nmap('<leader>gg', ':<C-u>Git commit -S<CR>', 'commit(with [g]pg)')
  nmap('<leader>gG', ':<C-u>Git commit --amend -S<CR>', 'modify prev commit msg(with [G]pg)')
end

-- other
nmap('<leader>gb', ':<C-u>Git blame<CR>', '[b]lame open')
nmap('<leader>gp', ':<C-u>Git push<CR>', '[p]ush to remote')
nmap('<leader>gs', ':<C-u>Git<CR>', '[s]tatus tool open')

return M
