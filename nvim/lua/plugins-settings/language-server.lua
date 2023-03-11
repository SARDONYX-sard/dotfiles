-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},

  -- jsonls = {
  --   json = {
  --     schemas = vim.list_extend({
  --       {
  --         description = 'VSCode devcontaier',
  --         fileMatch = { 'devcontainer.json' },
  --         name = 'devcontaier.json',
  --         url = 'https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainer.schema.json',
  --       },
  --     }, require('schemastore').json.schemas {}),
  --   },
  -- },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

--  This function gets run when an LSP connects to a particular buffer.
-- LSP settings.
local on_attach = function(_, buffer)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc })
  end

  nmap('<F2>', vim.lsp.buf.rename, 'Rename')
  nmap('<leader>lr', vim.lsp.buf.rename, 'Rename')
  nmap('<leader>la', vim.lsp.buf.code_action, 'Code Action')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>ltD', vim.lsp.buf.type_definition, 'Type Definition')
  nmap('<leader>ls', require('telescope.builtin').lsp_document_symbols, 'Document [S]ymbols')
  nmap('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  require('which-key').register { ['<leader>lw'] = { name = '+Lsp Workspace' } }
  nmap('<leader>lwa', vim.lsp.buf.add_workspace_folder, 'Workspace [A]dd Folder')
  nmap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'Workspace [R]emove Folder')
  nmap('<leader>lwl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(buffer, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
  nmap('<space>lf', function()
    vim.lsp.buf.format { async = true }
  end, 'format')
end

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

if vim.fn.executable 'node' then
  require('lspconfig').jsonls.setup {
    settings = {
      json = {
        schemas = vim.list_extend({
          {
            description = 'VSCode devcontaier',
            fileMatch = { 'devcontainer.json' },
            name = 'devcontaier.json',
            url = 'https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainer.schema.json',
          },
        }, require('schemastore').json.schemas {}),
      },
    },
  }
end

-- nvim-cmp setup
local cmp = require 'cmp'
local luasnip = require 'luasnip'

luasnip.config.setup {}

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
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

require('which-key').register { ['<leader>l'] = { name = '+Lsp' } }
vim.keymap.set('n', '<leader>lI', ':Mason<CR>', { noremap = true, silent = true, desc = 'installer' })
vim.keymap.set('n', '<space>li', ':LspInfo<CR>', { noremap = true, silent = true, desc = 'info' })
vim.keymap.set('n', '<space>ll', ':LspLog<CR>', { noremap = true, silent = true, desc = 'log' })
