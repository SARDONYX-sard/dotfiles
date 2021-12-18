#!/usr/bin/env bash

# reference (https://dev.classmethod.jp/articles/zsh-prezto/)
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

#? The following has already been written to .zshrc
#? So, for standalone installation
# Backup
# mkdir zsh_orig && mv zshmv .zlogin .zlogout .zprofile .zshenv .zshrc zsh_orig

# Create settings files
# eval '
# setopt EXTENDED_GLOB
# for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
#   ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
# done
# '
