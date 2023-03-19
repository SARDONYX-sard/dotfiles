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

      ---Normal mode buffer keymaps creator function.
      ---@param buf_num number
      local buf_nmap = function(buf_num)
        vim.keymap.set('n', '<leader>b' .. buf_num, function()
          require('bufferline').go_to_buffer(buf_num, true)
        end, { silent = true, desc = 'Buffer: ' .. buf_num })
      end
      for i = 1, 9 do
        buf_nmap(i)
      end

      ---Normal mode buffer keymaps creator function.
      ---@param keys string
      ---@param func function|string
      ---@param desc string
      local nmap = function(keys, func, desc)
        if desc then
          desc = 'Buffer: ' .. desc
        end
        vim.keymap.set('n', keys, func, { noremap = true, silent = true, desc = desc })
      end
      nmap('<S-Tab>', ':BufferLineCyclePrev<CR>', 'Buffer: prev')
      nmap('<Tab>', ':BufferLineCycleNext<CR>', 'Buffer: next')
      nmap('H', ':BufferLineCyclePrev<CR>', 'Buffer: prev')
      nmap('L', ':BufferLineCycleNext<CR>', 'Buffer: next')
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

return M
