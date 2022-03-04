#!/usr/bin/env bash

# Download Znap, if it's not there yet.
[[ -f ~/Git/zsh-snap/znap.zsh ]] ||
  git clone --depth 1 -- \
    https://github.com/marlonrichert/zsh-snap.git ~/Git/zsh-snap

source ~/Git/zsh-snap/znap.zsh # Start Znap

if [ -e /mnt/c ]; then
  # `znap source` automatically downloads and starts your plugins.
  znap source marlonrichert/zsh-autocomplete
  znap source zsh-users/zsh-autosuggestions
  znap source zdharma-continuum/fast-syntax-highlighting
fi

if [ -e /c ]; then
  #! msys2 will give an error, so load directly.
  if [ ! -e "$HOME"/Git//zsh-autocomplete ]; then
    znap install marlonrichert/zsh-autocomplete zsh-users/zsh-autosuggestions \
      zdharma-continuum/fast-syntax-highlighting
  fi

  source "$HOME"/Git//zsh-autocomplete/zsh-autocomplete.plugin.zsh
  source "$HOME"/Git/zsh-autosuggestions/zsh-autosuggestions.zsh
  source "$HOME"/Git/zdharma-continuum/fast-syntax-highlighting/fast-syntax-highlighting.zsh
fi

# `znap eval` caches and runs any kind of command output for you.
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

# shellcheck disable=SC2059
# `znap function` lets you lazy-load features you don't always need.
znap function _pyenv pyenvn 'eval "$( pyenv init - --no-rehash )"'
compctl -K _pyenv pyenv
