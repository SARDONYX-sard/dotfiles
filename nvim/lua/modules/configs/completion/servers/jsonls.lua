-- https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/jsonls.lua

local devcontaier_schema = {
  description = 'VSCode devcontaier',
  fileMatch = { 'devcontainer.json' },
  name = 'devcontaier.json',
  url = 'https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainer.schema.json',
}

return {
  flags = { debounce_text_changes = 500 },
  settings = {
    json = {
      -- Schemas https://www.schemastore.org
      schemas = {
        vim.list_extend({
          devcontaier_schema,
        }, require('schemastore').json.schemas {}),
      },
    },
  },
}
