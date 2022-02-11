#!/usr/bin/env bash

bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

n
y
y

#nodejs libs
pnpm install -g neovim tree-sitter-cli

# python libs
pip install codespell

if (which apt) >/dev/null 2>&1; then
  asdf reshim python
fi
