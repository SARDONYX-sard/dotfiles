#!/usr/bin/env bash

#! have to answer these questions manually.
if (which lvim) >/dev/null 2>&1; then # dev/null reference (https://qiita.com/ritukiii/items/b3d91e97b71ecd41d4ea)
  echo "$(tput setaf 3)"[Skip] lunarvim already installed."$(tput sgr0)"
else

  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) --no-install-dependencies

  #nodejs libs
  if (which npm) >/dev/null 2>&1; then
    npm install -g neovim tree-sitter-cli
  fi

  # python libs
  if (which pip) >/dev/null 2>&1; then
    sudo apt install python3-pip
  fi

  pip install codespell

  if (which asdf) >/dev/null 2>&1; then
    asdf reshim python
  fi

  cd "$HOME_DIR"/dotfiles/ || exit
  echo "$(tput setaf 3)"Running: git checkout HEAD ."$(tput sgr0)"
  echo "$(tput setaf 3)"Because back to my custom lvim-config.lua"$(tput sgr0)"

  git checkout HEAD .

fi
