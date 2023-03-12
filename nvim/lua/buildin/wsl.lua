-- clipboard settings(vim's registers == clipboard)
if os.getenv 'WSL_INTEROP' or os.getenv 'WSL_DISTRO_NAME' then
  -- In case of WSL, specify the windows clipboard to prevent `display = ":0" error`.
  -- - https://github.com/asvetliakov/vscode-neovim/issues/103
  -- - https://github.com/Microsoft/WSL/issues/892
  if vim.fn.has 'clipboard' or vim.fn.exists 'g:vscode' then
    vim.api.nvim_create_augroup('WSLYank', {})
    vim.api.nvim_create_autocmd('TextYankPost', {
      group = 'WSLYank',
      callback = function()
        vim.cmd [[ if v:event.operator ==# 'y' | call system('/mnt/c/Windows/System32/clip.exe', @0) | endif ]]
      end,
    })
  end
end
