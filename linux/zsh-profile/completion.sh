#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------
# Completion
# --------------------------------------------------------------------------------------------------
# enable completion features
autoload -Uz compinit && compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion

# tabtab source for packages(uninstall by removing these lines)
if [[ -f "$HOME"/.config/tabtab/zsh/__tabtab.zsh ]]; then
  . "$HOME"/.config/tabtab/zsh/__tabtab.zsh
else
  true
fi

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi
