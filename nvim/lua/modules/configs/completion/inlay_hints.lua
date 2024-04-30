--- inlay_hint manager
--- NOTE: Neovim inlay hint supported >=0.10
---
--- The following versions are assumed NVIM v0.10.0-dev-3045+gefaf37a2b
local M = {}

---@param event string
---@param is_enabled boolean
--- - ref: help lsp-inlay_hint
local function inlay_hint_on(event, is_enabled)
  vim.api.nvim_create_autocmd(event, {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
      if vim.lsp.inlay_hint == nil then
        return
      end

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local supported_inlayhint = client and client.server_capabilities and client.server_capabilities.inlayHintProvider

      if supported_inlayhint then
        vim.lsp.inlay_hint.enable(is_enabled)
      end
    end,
  })
end

--- - NOTE: Neovim inlay hint supported >=0.10. If you call with unsupported Neovim, it does nothing.
--- - ref: https://www.reddit.com/r/neovim/comments/14e41rb/today_on_nightly_native_lsp_inlay_hint_support/
function M.only_insert()
  inlay_hint_on('InsertEnter', false)
  inlay_hint_on('InsertLeave', true)
end

--- - NOTE: Neovim inlay hint supported >=0.10. If you call with unsupported Neovim, it does nothing.
function M.on_lsp_attach()
  inlay_hint_on('LspAttach', true)
end

--- Register toggle key
---@param mode string|nil -- default: 'n'
---@param key string|nil -- default: '\<leader\>lh'
function M.toggle_inlayhint_key(mode, key)
  if vim.lsp.inlay_hint == nil then
    return
  end

  vim.keymap.set(mode or 'n', key or '<leader>lh', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
  end, { silent = true, desc = 'lsp: Toggle inlayhint' })
end

return M
