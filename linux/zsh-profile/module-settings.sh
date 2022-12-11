#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------
# Modules settings
# --------------------------------------------------------------------------------------------------
if [ -e /mnt/c ]; then # only WSL
  source "${HOME_DIR}/AppData/Roaming/dystroy/broot/config/launcher/bash/br"
elif [ -e "$HOME"/.config/broot/launcher/bash/br ]; then # For Linux
  source "$HOME"/.config/broot/launcher/bash/br
fi

# --------------------------------------------------------------------------------------------------
# fzf
# --------------------------------------------------------------------------------------------------
if (command -v fzf) >/dev/null 2>&1; then # For ctrl key
  bindkey '^I' fzf_completion
fi

# To use Ctrl+R, Ctrl+T for fzf
[ -e "$HOME_DIR"/dotfiles/linux/zsh-profile/key-bindings.zsh ] && source "$HOME_DIR"/dotfiles/linux/zsh-profile/key-bindings.zsh

export FZF_DEFAULT_OPTS='--height 90% --layout=reverse --border'

if (command -v rg) >/dev/null 2>&1; then
  export FZF_CTRL_T_COMMAND='rg --max-depth 1 --files --hidden --follow --glob "!.git/*"'

  if (command -v batcat) >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--tabstop=4 --preview \"batcat --pager=never --color=always --style=numbers --line-range :300 {}\""
  elif (command -v bat) >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--tabstop=4 --preview \"bat --pager=never --color=always --style=numbers --line-range :300 {}\""
  else
    export FZF_CTRL_T_OPTS="--tabstop=4 --preview \"cat {}\""
  fi
fi

# basic file preview for ls (you can replace with something more sophisticated than head)
zstyle ':completion::*:ls::*' fzf-completion-opts --preview='eval head {1}'

# preview when completing env vars (note: only works for exported variables)
# eval twice, first to unescape the string, second to expand the $variable
zstyle ':completion::*:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-completion-opts --preview='eval eval echo {1}'

# preview a `git status` when completing git add
zstyle ':completion::*:git::git,add,*' fzf-completion-opts --preview='git -c color.status=always status --short'

# if other subcommand to git is given, show a git diff or git log
zstyle ':completion::*:git::*,[a-z]*' fzf-completion-opts --preview='
eval set -- {+1}
for arg in "$@"; do
    { git diff --color=always -- "$arg" | git log --color=always "$arg" } 2>/dev/null
done'

# fshow - git commit browser
fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" |
      fzf-tmux -d $((2 + $(wc -l <<<"$branches"))) +m) &&
    git checkout "$(echo "$branch" | sed \"s/.* //" | sed \"s#remotes/[^/]*/##")"
}

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) fzf "$@" --preview 'tree -C {} | head -200' ;;
  export | unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
  ssh) fzf "$@" --preview 'dig {}' ;;
  *) fzf "$@" ;;
  esac
}
