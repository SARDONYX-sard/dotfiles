-- Simple and lightweight GUI client for Neovim
-- https://github.com/hismailbulut/Neoray

if vim.g.neoray then
  vim.cmd 'NeoraySet CursorAnimTime 0.08'
  vim.cmd 'NeoraySet Transparency 0.6'
  vim.cmd 'NeoraySet TargetTPS 120'
  vim.cmd 'NeoraySet ContextMenu TRUE'
  vim.cmd 'NeoraySet BoxDrawing TRUE'
  vim.cmd 'NeoraySet ImageViewer TRUE'
  vim.cmd 'NeoraySet WindowSize 100x40'
  vim.cmd 'NeoraySet WindowState centered'
  vim.cmd 'NeoraySet KeyFullscreen <M-C-CR>'
  vim.cmd 'NeoraySet KeyZoomIn <C-ScrollWheelUp>'
  vim.cmd 'NeoraySet KeyZoomOut <C-ScrollWheelDown>'
end
