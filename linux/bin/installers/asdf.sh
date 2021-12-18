#!/usr/bin/env bash

# http://asdf-vm.com/guide/getting-started.html#_1-install-dependencies

apt install curl git
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1

asdf plugin add go
asdf plugin add nodejs
asdf plugin add python
asdf plugin add ruby
asdf plugin add deno

#? The rust plugin is deprecated because rustup allows you to put a .rust-toolchain file in your project.
# asdf plugin add rust

asdf install go latest
asdf install nodejs lts
asdf install python latest
asdf install ruby latest
