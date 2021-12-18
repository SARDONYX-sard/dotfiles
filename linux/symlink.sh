#!/bin/bash

# ? Strict setting of immediate termination if an error occurs.(for test command)
# -u(nounset): During parameter expansion, if there are any variables that have not been set, an error will occur.
# -e(errexit): If a command or pipeline returns a non-zero status, the shell will exit immediately.
# -x(execute): Print commands and their arguments as they are executed.
# -o(option-name): If any command in a pipeline has a non-zero exit status, the entire pipeline will be non-zero.
set -euxo pipefail

#! If you edit a file in the Ubuntu environment (VolFS) from a Windows application, that file will be corrupted.
#! Never mess with files in the Ubuntu environment from Windows applications.
# see(https://kledgeb.blogspot.com/2017/01/wsl-70-bashwindows.html)
# Example:
#     `Symlink target`` → `Destination``
#          windows      →     Ubuntu       => OK!
#           Ubuntu      →     windows      => Not recommended!

# reference: (https://www.reddit.com/r/bashonubuntuonwindows/comments/8dhhrr/is_it_possible_to_get_the_windows_username_from/)
HOME_DIR="$HOME"
if [ -e /mnt/c ]; then # Current shell is WSL?
  WINDOWS_USER=$(/mnt/c/Windows/System32/cmd.exe /c 'echo %USERNAME%' | sed -e 's/\r//g')
  HOME_DIR="/mnt/c/Users/$WINDOWS_USER"
fi

# If the link is to a directory, it will fail.
# (you can force it with -n, but it might be dangerous)

# vim
sudo ln -sf "$HOME_DIR"/dotfiles/init.vim "$HOME"/.vimrc

# Neovim
mkdir -p "$HOME_DIR"/.config/nvim
sudo ln -sf "$HOME_DIR"/dotfiles/init.vim "$HOME"/.config/nvim/init.vim
sudo ln -sf "$HOME_DIR"/dotfiles/ginit.vim "$HOME"/.config/nvim/ginit.vim

# dot rc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.bash_profile "$HOME"/.bash_profile
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.bashrc "$HOME"/.bashrc

sudo ln -sf "$HOME_DIR"/dotfiles/common/.zshrc "$HOME"/.zshrc

# vim plugins
mkdir -p "$HOME_DIR"/.config/nvim
test ! -d "$HOME_DIR"/.config/nvim/coc-settings.json
sudo ln -sf "$HOME_DIR"/dotfiles/common/coc-settings.json "$HOME_DIR"/.config/nvim/coc-settings.json

# alias, functions, environment paths
sudo ln -sf "$HOME_DIR"/dotfiles/common/read-common-settings.sh "$HOME"/common/read-common-settings.sh
