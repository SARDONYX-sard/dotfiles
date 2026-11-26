vim.keymap.set('n', '<space>v', function()
  local pwd = vim.fn.expand '%:p:h'

  if vim.fn.executable 'explorer.exe' == 1 and vim.fn.executable 'powershell.exe' == 1 then
    if vim.fn.has 'win32' == 1 then
      vim.fn.system('explorer.exe ' .. pwd)
      return
    else
      if vim.fn.has 'wsl' == 1 then
        pwd = vim.fn.system("bash -c 'wslpath -w " .. pwd .. "'")
      elseif vim.fn.has 'win32unix' == 1 then
        pwd = vim.fn.system("bash -c 'cygpath -w " .. pwd .. "'")
      end
      -- NOTE: Cannot jump to path location correctly without powershell.
      vim.fn.system("powershell.exe -c 'explorer.exe " .. pwd .. "'")
      return
    end
  elseif vim.fn.has 'linux' == 1 and vim.fn.executable 'xdg-open' == 1 then
    vim.fn.system('xdg-open ' .. pwd)
    return
  elseif vim.fn.has 'mac' == 1 and vim.fn.executable 'open' == 1 then
    vim.fn.system('open ' .. pwd)
    return
  end

  vim.notify(
    'Failed to open the directory(' .. pwd .. ') because there is no expected command',
    vim.log.levels.ERROR,
    { title = 'init.lua' }
  )
end, { desc = '[V]iew(Open) current dir with GUI' })
