# https://github.com/LunarVim/LunarVim

Invoke-WebRequest https://raw.githubusercontent.com/LunarVim/LunarVim/master/utils/installer/install.ps1 -UseBasicParsing | Invoke-Expression


# If you want to use your neovim default settings too
# ln -s "$HOME\AppData\Roaming\lunarvim\lvim\lua\lvim" "$HOME\AppData\Local\nvim\lua"
# ln -s "$HOME\dotfiles\lvim-config.lua" "$HOME\AppData\Local\nvim\config.lua"
# ln -s "$HOME\dotfiles\init.lua" "$HOME\AppData\Local\nvim\lua\init.lua"
