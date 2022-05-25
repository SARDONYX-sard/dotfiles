#!/usr/bin/env bash

# dependencies: curl git

# http://asdf-vm.com/guide/getting-started.html#_1-install-dependencies

echo "$(tput setaf 4)"adsf installing..."$(tput sgr0)"

if (! which asdf) >/dev/null 2>&1; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
fi

source . "$HOME"/.bashrc

asdf update
asdf plugin add nodejs
asdf plugin add ruby

#? The rust plugin is deprecated because rustup allows you to put a .rust-toolchain file in your project.
# asdf plugin add rust

if [ "$IS_LIGHT" ]; then
  echo "$(tput setaf 2)"Light mode enabled. no install languages."$(tput sgr0)"
else
  asdf install nodejs lts
  # asdf install python latest
  # asdf install ruby latest

  corepack enable pnpm yarn npm
  asdf reshim
fi

if (! which fish) >/dev/null 2>&1; then
  mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
fi
