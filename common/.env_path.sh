#!/usr/bin/env bash

if (which lvim) >/dev/null 2>&1; then
  export EDITOR=lvim
elif (which nvim) >/dev/null 2>&1; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi

# Homebrew for oh-my-posh linux
[ -f /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# For WSL
DISPLAY="$(ip route | awk '/default via / {print $3}'):0"
[ -e /mnt/c ] && export DISPLAY

# for personal's bash files
PATH="$PATH:$HOME/.local/bin"

CURRENT_SHELL=$(ps -ocomm= -q $$)
export CURRENT_SHELL

# asdf(lang manager)
[ -e "$HOME"/.asdf/asdf.sh ] && . "$HOME"/.asdf/asdf.sh
[ "$CURRENT_SHELL" = "bash" ] && [ -e "$HOME"/.asdf/completions/asdf.bash ] && . "$HOME"/.asdf/completions/asdf.bash

# rust
[ -e "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Docker: Ensure that untrusted images cannot be pulled.
# - https://docs.docker.com/engine/security/trust/
export DOCKER_CONTENT_TRUST=1

# deno
if [ -e "$HOME/.deno" ]; then
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
fi

# bun(Incredibly fast JavaScript runtime, bundler, transpiler and package manager)
if [ -e "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# opam: OCaml Package Manager
# - https://opam.ocaml.org
if [[ "$SHELL" =~ zsh ]]; then
  [[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>/dev/null
elif [[ "$SHELL" =~ bash ]]; then
  [[ ! -r "$HOME/.opam/opam-init/init.sh" ]] || source "$HOME/.opam/opam-init/init.sh" >/dev/null 2>/dev/null
fi

# Where user-specific configurations should be written
# - https://wiki.archlinux.org/title/XDG_Base_Directory#User_directories
export XDG_BASE_HOME="$HOME/.config"

function get_asdf_lang_version() {
  local lang=$1
  return "$(asdf current "$lang" | sed -E "s/$lang|\/home.*//g" | sed 's/ //g')"
}

if [ "$(command -v node)" ]; then
  NODEV=$(node -v | sed -E "s/v//g")
fi

export ASDFINSTALLS=$HOME/.asdf/installs
export ASDFROOT=$HOME/.asdf
export CODEROOT=$HOME/code
export DOCKER_PGPASS=
export DOCKER_PGUSER=
# export GOPATH=$HOME/code/go
# export GOROOT=$ASDFINSTALLS/golang/$GOV/go/
export NODEROOT=$ASDFINSTALLS/nodejs/$NODEV
export NODEV=$NODEV
export PGHOST=localhost
export PGPASSWORD=
export PGPORT=5432
export PGUSER=$USER
export RUSTPATH=$HOME/.cargo/bin
export http_proxy=
