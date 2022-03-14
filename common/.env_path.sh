#!/usr/bin/env bash

if (which lvim) >/dev/null 2>&1; then
  export EDITOR=lvim
else
  export EDITOR=vim
fi

# Homebrew for oh-my-posh linux
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# For WSL
DISPLAY="$(ip route | awk '/default via / {print $3}'):0"
[ -e /mnt/c ] && export DISPLAY

# for personal's bash files
PATH="$PATH:$HOME/.local/bin"

# heroku CLI
PATH=/usr/local/heroku/bin:$PATH

CURRENT_SHELL=$(ps -ocomm= -q $$)
export CURRENT_SHELL

# asdf(lang manager): ruby, node.js
# ! Describe the asdf path below the heroku path!
# ? Reason: to prevent version overwriting by node.js in heroku.
[ -e "$HOME"/.asdf/asdf.sh ] && . "$HOME"/.asdf/asdf.sh
[ "$CURRENT_SHELL" = "bash" ] && . "$HOME"/.asdf/completions/asdf.bash

# rust
[ -e "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Docker
export DOCKER_CONTENT_TRUST=1

# deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

# Neovim
export XDG_BASE_HOME="$HOME/.config"

function get_asdf_lang_version() {
  local lang=$1
  return "$(asdf current "$lang" | sed -E "s/$lang|\/home.*//g" | sed 's/ //g')"
}

if [ "$(command -v node)" ]; then
  NODEV=$(get_asdf_lang_version nodejs)
fi
export ASDFINSTALLS=$HOME/.asdf/installs
export ASDFROOT=$HOME/.asdf
export CODEROOT=$HOME/code
export DOCKER_PGPASS=
export DOCKER_PGUSER=
export EDITOR=vim
export GOPATH=$HOME/code/go
# export GOROOT=$ASDFINSTALLS/golang/$GOV/go/
export NODEROOT=$ASDFINSTALLS/nodejs/$NODEV
export NODEV=$NODEV
export PGHOST=localhost
export PGPASSWORD=
export PGPORT=5432
export PGUSER=$USER
export RUSTPATH=$HOME/.cargo/bin
export http_proxy=
