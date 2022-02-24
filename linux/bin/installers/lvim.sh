#!/usr/bin/env bash

#! have to answer these questions manually.
bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

#nodejs libs
pnpm install -g neovim tree-sitter-cli

# python libs
pip install codespell

if (which apt) >/dev/null 2>&1; then
  asdf reshim python
fi

cd "$HOME_DIR"/dotfiles/ || exit
echo "$(tput setaf 3)"Running: git checkout HEAD ."$(tput sgr0)"
echo "$(tput setaf 3)"Because back to my custom lvim-config.lua"$(tput sgr0)"

git checkout HEAD .
