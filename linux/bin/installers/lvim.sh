#!/usr/bin/env bash

bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

n
y
y

#nodejs libs
pnpm install -g neovim tree-sitter-cli

# python libs
pip install codespell
