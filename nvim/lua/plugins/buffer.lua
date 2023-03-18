-- In vim, buffer and window are different, and it seems that one window can contain multiple buffers.
local M = {}

M.plugins = {
  {
    'akinsho/bufferline.nvim',
    version = 'v3.*',
    dependencies = {
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      vim.opt.termguicolors = true

      require('bufferline').setup {
        options = {
          numbers = 'ordinal',
          diagnostics = 'nvim_lsp',
          separator_style = 'thick',
          custom_filter = function(buf, _)
            return vim.bo[buf].filetype ~= 'qf'
          end,
          offsets = {
            {
              filetype = 'NvimTree',
              text = function()
                return vim.fn.getcwd()
              end,
              highlight = 'Directory',
              text_align = 'left',
            },
          },
        },
      }

      pcall(require('which-key').register, {
        ['<leader>b'] = {
          name = '+Buffer',
        },
      })
    end,
  },

  {
    -- Automagically follow symlinks
    --
    -- In the case of a symlinked init.lua file,
    -- install it in order to follow the link and edit it.
    'aymericbeaumet/vim-symlink',
    dependencies = { 'moll/vim-bbye' },
  },
}

---Normal mode buffer keymaps creator function.
---@param buf_num number
local nmap = function(buf_num)
  vim.keymap.set('n', '<leader>b' .. buf_num, function()
    require('bufferline').go_to_buffer(buf_num, true)
  end, { silent = true, desc = 'Buffer: ' .. buf_num })
end
for i = 1, 10, 1 do
  nmap(i)
end

vim.keymap.set('n', 'L', ':BufferLineCycleNext<CR>', { silent = true, desc = 'Buffer: next' })
vim.keymap.set('n', 'H', ':BufferLineCyclePrev<CR>', { silent = true, desc = 'Buffer: prev' })
vim.keymap.set('n', '<space>c', ':bdelete<CR>', { silent = true, desc = 'Buffer: [c]lose' })
--See: https://stackoverflow.com/questions/4545275/vim-close-all-buffers-but-this-one
vim.keymap.set('n', '<space>bo', ':%bd|e#|bd#<CR>', { silent = true, desc = 'Buffer: [o]nly current' })

return M
