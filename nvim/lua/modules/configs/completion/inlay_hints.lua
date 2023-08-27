--- inlay_hint manager
--- NOTE: Neovim inlay hint supported >=0.10
local M = {}
--- Use your own global variables because We can't find a way to get the state.
vim.g.inlayhint_enabled = false

---@param event string
---@param on_or_off boolean
--- - ref: https://vinnymeller.com/posts/neovim_nightly_inlay_hints/#globally
local function inlay_hint_on(event, on_or_off)
  vim.api.nvim_create_autocmd(event, {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
      if vim.lsp.inlay_hint == nil then
        return
      end

      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local supported_inlayhint = client and client.server_capabilities and client.server_capabilities.inlayHintProvider

      if supported_inlayhint then
        vim.lsp.inlay_hint(args.buf, on_or_off)
        vim.g.inlayhint_enabled = on_or_off
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

function M.toggle_inlayhint_key()
  local toggle_inlayhint = function()
    vim.g.inlayhint_enabled = not vim.g.inlayhint_enabled
    vim.lsp.inlay_hint(vim.api.nvim_get_current_buf(), vim.g.inlayhint_enabled)
  end
  vim.keymap.set('n', '<leader>lh', toggle_inlayhint, { silent = true, desc = 'lsp: Toggle inlayhint' })
end

return M
