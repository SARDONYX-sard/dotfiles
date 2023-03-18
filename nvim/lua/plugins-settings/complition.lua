-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.config.setup()
require('cmp_git').setup()

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },

  formatting = {
    format = function(entry, vim_item)
      local source_mapping = {
        buffer = '[Buffer]',
        cmp_tabnine = '[Tabnine]',
        emoji = '[emoji]',
        git = '[Git]',
        nvim_lsp = '[LSP]',
        nvim_lua = '[Lua]',
        path = '[Path]',
      }

      -- if you have lspkind installed, you can use it like
      -- in the following line:
      vim_item.kind = require('lspkind').symbolic(vim_item.kind, { mode = 'symbol' })
      vim_item.menu = source_mapping[entry.source.name]
      if entry.source.name == 'cmp_tabnine' then
        local detail = (entry.completion_item.data or {}).detail
        vim_item.kind = ''
        if detail and detail:find '.*%%.*' then
          vim_item.kind = vim_item.kind .. ' ' .. detail
        end

        if (entry.completion_item.data or {}).multiline then
          vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
        end
      end
      local maxwidth = 80
      vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
      return vim_item
    end,
  },

  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
      require 'cmp_tabnine.compare',
    },
  },

  sources = cmp.config.sources {
    { name = 'cmp_tabnine' },
    { name = 'emoji' }, -- trigger `:`
    { name = 'git' }, --It completes the issue number and PR number at commit time. (triggered by `@` or `#`)
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lua' },
    { name = 'path' }, -- Trigerd by `/`
    {
      name = 'buffer',
      option = {
        keyword_length = 5,
        get_bufnrs = function()
          local bufs = {}
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            bufs[vim.api.nvim_win_get_buf(win)] = true
          end
          return vim.tbl_keys(bufs)
        end,
      },
    },
  },
}

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    {
      name = 'buffer',
      option = {
        keyword_length = 5,
      },
    },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})
