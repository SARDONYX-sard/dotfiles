#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------
# History settings
# --------------------------------------------------------------------------------------------------
# History configurations
HISTFILE="$HOME/.zsh_history" #履歴を保存するファイル指定
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# enable auto-suggestions based on the history
if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  . /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  # change suggestion color
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi
