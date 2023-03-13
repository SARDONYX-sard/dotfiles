-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.

-- See: https://github.com/LuaLS/lua-language-server/wiki/Annotations#field
---
---@class LanguageServers
---@field [string] LspConfig  -Lsp name(e.g. 'clangd' | 'gopls')

---@class LspConfig settings items
---@field capabilities table -nvim-cmp supports additional completion capabilities, so broadcast that to servers.
---@field require_cmd string -Dependent on this command path being passed.(e.g. 'node')

--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
---@type LanguageServers
local servers = {
  clangd = {
    ---To suppress `clangd` encoding warning
    ---See: https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
    capabilities = (function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
      capabilities.offsetEncoding = { 'utf-16' }
      return capabilities
    end)(),
  },
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},

  jsonls = {
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
    require_cmd = 'node',
  },
  -- Neovim itself has a Lua execution environment,
  -- so there is no need to include external commands on its own initiative.
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
  ---@param keys string
  ---@param func function|string
  ---@param desc string
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc })
  end

  nmap('<F2>', vim.lsp.buf.rename, 'Rename')
  nmap('<leader>lr', vim.lsp.buf.rename, '[r]ename')
  nmap('<leader>la', vim.lsp.buf.code_action, 'Code [a]ction')

  nmap('gd', vim.lsp.buf.definition, '[g]oto [d]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[g]oto [r]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[g]oto [I]mplementation')
  nmap('<leader>lt', vim.lsp.buf.type_definition, '[t]ype Definition')
  nmap('<leader>ls', require('telescope.builtin').lsp_document_symbols, 'Show Document [s]ymbols')
  nmap('<leader>lws', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace: [s]ymbols')

  -- See `:help K` for why this keymap
  -- nmap('K', vim.lsp.buf.hover, 'Hover Documentation') -- I use `hover.nvim` instead of it.
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[g]oto [D]eclaration')

  require('which-key').register { ['<leader>lw'] = { name = '+Lsp [w]orkspace' } }
  nmap('<leader>lwa', vim.lsp.buf.add_workspace_folder, 'Workspace: [a]dd Folder')
  nmap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, 'Workspace: [r]emove Folder')
  nmap('<leader>lwl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, 'Workspace: [l]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(buffer, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
  nmap('<space>lf', function()
    vim.lsp.buf.format { async = true }
  end, '[f]ormat')
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
  ensure_installed = (function()
    -- json_ls, etc. will cause an error if there is no `node`,
    -- so if there is no `node`, exclude it here.
    for _, server_name in ipairs(vim.tbl_keys(servers)) do
      if servers[server_name].require_cmd ~= nil and vim.fn.executable(servers[server_name].require_cmd) == 0 then
        -- Remove dependencies on external commands by putting nil in the server configuration.
        servers[server_name] = nil
      end
    end

    return vim.tbl_keys(servers)
  end)(),
}

mason_lspconfig.setup_handlers {
  ---@param server_name string
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = (function()
        if servers[server_name] ~= nil and servers[server_name].capabilities ~= nil then
          return servers[server_name].capabilities
        end
        return capabilities
      end)(),
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}

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

---Prevent multi hover notifications warning.
---See: https://github.com/neovim/neovim/issues/20457#issuecomment-1266782345
---@param _ any
---@param result table
---@param ctx table
---@param config table
---@return integer|nil|unknown
vim.lsp.handlers['textDocument/hover'] = function(_, result, ctx, config)
  config = config or {}
  config.focus_id = ctx.method
  if not (result and result.contents) then
    return
  end
  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
  if vim.tbl_isempty(markdown_lines) then
    return
  end
  return vim.lsp.util.open_floating_preview(markdown_lines, 'markdown', config)
end

-- Nonattach lsp keymaps
--
---Normal mode lsp keymap creator function.
---@param keys string
---@param func function|string
---@param desc string
local nmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end
  vim.keymap.set('n', keys, func, { noremap = true, silent = true, desc = desc })
end
require('which-key').register { ['<leader>l'] = { name = '+Lsp' } }
nmap('<leader>lI', ':Mason<CR>', '[I]nstaller')
nmap('<space>li', ':LspInfo<CR>', '[i]nfo')
nmap('<space>ll', ':LspLog<CR>', '[l]og')
