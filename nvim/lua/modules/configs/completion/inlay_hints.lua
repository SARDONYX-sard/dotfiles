--- inlay_hint manager
--- NOTE: Neovim inlay hint supported >=0.10
local M = {}

---@param event string
---@param on_or_off boolean
--- - ref: https://vinnymeller.com/posts/neovim_nightly_inlay_hints/#globally
local function inlay_hint_on(event, on_or_off)
  vim.api.nvim_create_autocmd(event, {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
      -- I thought lua can check nil at the same time for short circuit evaluation for now,
      -- but I have to split it because of frequent errors in nightly
      if vim.lsp.inlay_hint == nil then
        return
      end

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client == nil then
        return
      end
      if client.server_capabilities == nil then
        return
      end

      if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint(args.buf, on_or_off)
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

return M
