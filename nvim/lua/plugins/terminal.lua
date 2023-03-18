-- https://github.com/akinsho/toggleterm.nvim

local M = {}

M.plugins = {
  {
    'akinsho/toggleterm.nvim',
    config = function()
      require('toggleterm').setup {
        size = function(term)
          if term.direction == 'horizontal' then
            return vim.o.lines * 0.2
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        shell = (function()
          if vim.fn.has 'win32' == 1 then
            if vim.fn.executable 'pwsh.exe' == 1 then
              return 'pwsh.exe'
            else
              return 'powershell.exe'
            end
          else
            if vim.fn.executable 'fish' == 1 then
              return 'fish'
            elseif vim.fn.executable 'zsh' == 1 then
              return 'zsh'
            else
              return 'bash'
            end
          end
        end)(),
        autochdir = true,
        -- close_on_exit = true,
        direction = 'horizontal', ---@type 'vertical' | 'horizontal' | 'window' | 'float'
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        open_mapping = '<C-l>',
        persist_size = false,
        shade_terminals = true,
        shading_factor = 2, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        winblend = 0,
        float_opts = {
          border = 'curved',
          highlights = {
            border = 'Normal',
            background = 'Normal',
          },
        },
      }

      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = 0, desc = 'Escape terminal' })
        vim.keymap.set('t', 'JK', [[<C-\><C-n>]], { buffer = 0, desc = 'Escape terminal' })
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
      end

      -- if you only want these mappings for toggle term use term://*toggleterm#* instead
      vim.cmd 'autocmd! TermOpen term://* lua set_terminal_keymaps()'
    end,
  },
}

return M
