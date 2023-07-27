--- inlay_hint manager
--- NOTE: Neovim inlay hint supported >=0.10
local M = {}

---@param on_or_off boolean
---@param bufnr number -- buffer numbler
---@return table
local function inlay_hint_turn(on_or_off, bufnr)
  return {
    buffer = bufnr,
    callback = function()
      vim.lsp.inlay_hint(bufnr, on_or_off)
    end,
    group = 'lsp_augroup',
  }
end

---@param _client any
---@param bufnr number -- buffer numbler
--- - NOTE: Neovim inlay hint supported >=0.10. If you call with unsupported Neovim, it does nothing.
--- - ref: https://www.reddit.com/r/neovim/comments/14e41rb/today_on_nightly_native_lsp_inlay_hint_support/
function M.only_insert(_client, bufnr)
  if vim.lsp.inlay_hint == nil then
    return
  end

  vim.api.nvim_create_augroup('lsp_augroup', { clear = true })
  vim.api.nvim_create_autocmd('InsertEnter', inlay_hint_turn(true, bufnr))
  vim.api.nvim_create_autocmd('InsertLeave', inlay_hint_turn(false, bufnr))
end

---@param _client any
---@param bufnr number -- buffer numbler
--- - NOTE: Neovim inlay hint supported >=0.10. If you call with unsupported Neovim, it does nothing.
function M.on_lsp_attach(_client, bufnr)
  if vim.lsp.inlay_hint == nil then
    return
  end
  vim.api.nvim_create_augroup('lsp_augroup', { clear = true })
  vim.api.nvim_create_autocmd('LspAttach', inlay_hint_turn(true, bufnr))
end

return M
