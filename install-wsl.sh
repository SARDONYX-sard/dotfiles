#!/bin/bash

if [ "$(whoami)" != "root" ] && [ "$SUDO_USER" != "" ]; then
  echo "Run with sudo."
  exit 1
fi

export HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  # windows home directory
  WIN_HOME=$(which scoop | sed -E 's/scoop.*//g')
  export WIN_HOME
  # windows user name
  WIN_USER=$(echo "$WIN_HOME" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER

  HOME_DIR=$WIN_HOME
fi

if [ ! -d "$HOME_DIR"/dotfiles ]; then
  echo "Not found $HOME_DIR/dotfiles/ dirctory."
  exit 1
fi

uname -a | grep microsoft >/dev/null 2>/dev/null
export is_wsl=$((!$?))

echo "Setting up symlink..."
bash "$HOME_DIR"/dotfiles/linux/symlink.sh

echo "Setting up git"
cat "$HOME_DIR"/dotfiles/common/data/git/git-config.txt >"$HOME"/.gitconfig

echo "Installation by package manager, etc."

if [ "$1" = "light" ]; then
  bash "$HOME_DIR"/dotfiles/linux/bin/all-installer.sh light
else
  bash "$HOME_DIR"/dotfiles/linux/bin/all-installer.sh
fi

if [ "$2" = "zsh" ]; then
  chsh -s /bin/zsh # Change shell to zsh.(option)
fi
