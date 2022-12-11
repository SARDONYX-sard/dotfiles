#!/usr/bin/env bash

#! have to answer these questions manually.
if (command -v lvim) >/dev/null 2>&1; then # dev/null reference (https://qiita.com/ritukiii/items/b3d91e97b71ecd41d4ea)
  echo "$(tput setaf 3)"[Skip] lunarvim already installed."$(tput sgr0)"
else

  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --no-install-dependencies

  #nodejs libs
  if (command -v npm) >/dev/null 2>&1; then
    npm install -g neovim tree-sitter-cli
  fi

  # for codespell
  if (command -v apt) >/dev/null 2>&1; then
    sudo apt install python3.10-venv
  fi

  cd "$HOME_DIR"/dotfiles/ || exit
  echo "$(tput setaf 3)"Running: git checkout HEAD ."$(tput sgr0)"
  echo "$(tput setaf 3)"Because back to my custom lvim-config.lua"$(tput sgr0)"

  git checkout HEAD .
  cd - || exit

fi
