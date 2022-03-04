#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------
# Shell behavior
# --------------------------------------------------------------------------------------------------
setopt auto_pushd          # pushd to the directory you are in
setopt autocd              # change directory just by typing its name
setopt correct             # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt ksharrays           # arrays start at 0
setopt list_packed         # show completion suggestions as closely as possible.
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt
setopt pushd_ignore_dups   # no pushd history is left.

WORDCHARS=${WORDCHARS//\//} # Don't consider certain characters part of the word

# hide EOL sign ('%')
export PROMPT_EOL_MARK=""

# # configure key keybindings
# bindkey -e                  # emacs key bindings
bindkey ' ' magic-space     # do history expansion on space
bindkey '^[[3;5~' kill-word # ctrl + Supr
# bindkey '^[[1;5C' forward-word                 # ctrl + ->
# bindkey '^[[C' forward-word                    # ctrl + ->
# bindkey '^[[1;5D' backward-word                # ctrl + <-
# bindkey '^[[D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history # page up
bindkey '^[[6~' end-of-buffer-or-history       # page down
bindkey '^[[Z' undo                            # shift + tab undo last action
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}" end-of-line
bindkey -v # vim mode zsh
