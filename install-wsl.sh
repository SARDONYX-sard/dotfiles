#!/bin/bash

if [ "$(whoami)" != "root" ] && [ "$SUDO_USER" != "" ]; then
  echo "Run with sudo."
  exit 1
fi

if [ ! -d "$HOME"/dotfiles ]; then
  echo "Not found $HOME/dotfiles/ dirctory."
  exit 1
fi

uname -a | grep microsoft >/dev/null 2>/dev/null
export is_wsl=$((!$?))

# Setting up symlink
bash ~/dotfiles/linux/symlink.sh

# -- Setting up git
cat "$HOME"/dotfiles/common/data/git-config.txt >"$HOME"/.gitconfig

# -- Installation by package manager, etc.
bash "$HOME"/dotfiles/linux/install.sh

# chsh -s /bin/zsh # Change shell to zsh.(option)
