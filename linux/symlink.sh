#!/bin/bash

# Usage: bash ./symlink.sh.
#! Please do not sudo bash ./symlink.sh Because $HOME is /root/ when use `sudo bash`

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
# WSL can assign windows $HOME.
HOME_DIR="$HOME"

if [ -e /mnt/c ]; then
  # windows home directory
  WIN_HOME=$(which scoop | sed -E 's/scoop.*//g')
  export WIN_HOME
  # windows user name
  WIN_USER=$(echo "$WIN_HOME" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER

  export HOME_DIR=$WIN_HOME
fi

# If the link is to a directory, it will fail.
# (you can force it with -n, but it might be dangerous)

# vim
sudo ln -sf "$HOME_DIR"/dotfiles/init.vim "$HOME"/.vimrc

# Neovim
mkdir -p "$HOME_DIR"/.config/nvim
sudo ln -sf "$HOME_DIR"/dotfiles/init.vim "$HOME"/.config/nvim/init.vim
sudo ln -sf "$HOME_DIR"/dotfiles/ginit.vim "$HOME"/.config/nvim/ginit.vim

mkdir -p "$HOME"/.config/lvim
sudo ln -sf "$HOME_DIR"/dotfiles/lvim-config.lua "$HOME"/.config/lvim/config.lua

# fish shell
mkdir -p "$HOME"/.config/fish
sudo ln -sf "$HOME_DIR"/dotfiles/linux/fishrc "$HOME"/.config/fish/config.fish
sudo ln -sf "$HOME_DIR"/dotfiles/linux/fish-profile/functions/ "$HOME"/.config/fish/functions/

# dot rc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.bashrc "$HOME"/.bashrc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.zshrc "$HOME"/.zshrc
sudo ln -sf "$HOME_DIR"/dotfiles/linux/.inputrc "$HOME"/.inputrc

# autokey
if which autokey >/dev/null || which autokey-shell >/dev/null; then
  mkdir -p "$HOME"/.config/autokey/data
  sudo ln -sf "$HOME_DIR"/dotfiles/common/data/autokey "$HOME"/.config/autokey/data
fi
