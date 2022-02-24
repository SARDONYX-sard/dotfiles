#!/usr/bin/env bash

#? need 585 MB Disk volume

HOME_DIR="$HOME"

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

if [ "$1" = "light" ]; then
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/apt.sh "light"
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/asdf.sh "light"
else
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/apt.sh
  bash "$HOME_DIR"/dotfiles/linux/bin/installers/asdf.sh
fi

bash "$HOME_DIR"/dotfiles/linux/bin/installers/autosuggestions.sh
bash "$HOME_DIR"/dotfiles/linux/bin/installers/fzf-tab-completion.sh
bash "$HOME_DIR"/dotfiles/linux/bin/installers/homebrew.sh
bash "$HOME_DIR"/dotfiles/linux/bin/installers/oh-my-posh.sh #! need brew command.
python3 "$HOME_DIR"/dotfiles/linux/bin/installers/pip.py

if (which rustup) >/dev/null 2>&1; then
  [ "$1" = "light" ] || bash "$HOME_DIR"/dotfiles/linux/bin/installers/rustup.sh
fi
