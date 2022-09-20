#!/usr/bin/env bash

# --------------------------------------------------------------------------------------------------
# editor setting
# --------------------------------------------------------------------------------------------------
if (which lvim) >/dev/null 2>&1; then
  export EDITOR=lvim
elif (which nvim) >/dev/null 2>&1; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi

# --------------------------------------------------------------------------------------------------
# Language settings
# --------------------------------------------------------------------------------------------------
# Where user-specific configurations should be written
# - https://wiki.archlinux.org/title/XDG_Base_Directory
# The directory for the configuration file is defined in the environment variable $XDG_CONFIG_HOME,
# and $HOME/.config is used if this is empty or undefined.
export XDG_BASE_HOME="$HOME/.config"

# Docker: Ensure that untrusted images cannot be pulled.
# - https://docs.docker.com/engine/security/trust/
export DOCKER_CONTENT_TRUST=1

# Homebrew for oh-my-posh linux
[ -f /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# For WSL
# DISPLAY="$(ip route | awk '/default via / {print $3}'):0"
# [ -e /mnt/c ] && export DISPLAY

# for personal's bash files
PATH="$HOME/.local/bin:$PATH"

CURRENT_SHELL=$(ps -ocomm= -q $$)
export CURRENT_SHELL

# --------------------------------------------------------------------------------------------------
# Language settings
# --------------------------------------------------------------------------------------------------
function get_asdf_lang_version() {
  local lang=$1
  return "$(asdf current "$lang" | sed -E "s/$lang|\/home.*//g" | sed 's/ //g')"
}

# asdf(lang manager)
if [ -e "$HOME"/.asdf/asdf.sh ]; then
  . "$HOME"/.asdf/asdf.sh
  export ASDFINSTALLS=$HOME/.asdf/installs
  export ASDFROOT=$HOME/.asdf

  if (asdf current node) >/dev/null 2>&1; then
    NODEV=$(node -v | sed -E "s/v//g")
    export NODEV=$NODEV
    export NODEROOT=$ASDFINSTALLS/nodejs/$NODEV
  fi

  if (asdf current go) >/dev/null 2>&1; then
    GOROOT=$ASDFINSTALLS/golang/$(get_asdf_lang_version "go")/go/
    export GOROOT
  fi

  [ "$CURRENT_SHELL" = "bash" ] &&
    [ -e "$HOME"/.asdf/completions/asdf.bash ] &&
    . "$HOME"/.asdf/completions/asdf.bash
fi

# deno(Incredibly fast JavaScript runtime, bundler, transpiler and package manager. written by rust)
[ -e "$HOME/.deno" ] && export DENO_INSTALL="$HOME/.deno" && export PATH="$DENO_INSTALL/bin:$PATH"

# bun(Incredibly fast JavaScript runtime, bundler, transpiler and package manager)
[ -e "$HOME/.bun" ] && export BUN_INSTALL="$HOME/.bun" && export PATH="$BUN_INSTALL/bin:$PATH"

# opam: OCaml Package Manager
# - https://opam.ocaml.org
if [[ "$SHELL" =~ zsh ]]; then
  [[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" >/dev/null 2>/dev/null
elif [[ "$SHELL" =~ bash ]]; then
  [[ ! -r "$HOME/.opam/opam-init/init.sh" ]] || source "$HOME/.opam/opam-init/init.sh" >/dev/null 2>/dev/null
fi

# rust
[ -e "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
