#!/usr/bin/env bash

echo "$(tput setaf 4)"apt installing libs..."$(tput sgr0)"

sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

[ "$IS_LIGHT" ] && sudo apt install clang -y

sudo apt install curl git zip -y
sudo apt install exuberant-ctags -y
sudo apt install neovim -y

# monitor
sudo apt install sysstat -y
sudo apt -y install htop

# coding
sudo apt install source-highlight -y

# instead of command
sudo apt install fd-find -y # find
sudo apt install gawk -y    # For fzf dependencies
sudo apt install fzf -y     # fuzzy finder
# (https://github.com/sharkdp/bat/issues/938#:~:text=sudo%20apt%20install%20%2Do%20Dpkg%3A%3AOptions%3A%3A%3D%22%2D%2Dforce%2Doverwrite%22%20bat%20ripgrep)
sudo apt install -o Dpkg::Options::="--force-overwrite" bat ripgrep -y # bat==cat / grep written in rust

sudo apt install silversearcher-ag -y # This is a command to perform recursive string searches on files. In short, the awesome grep(https://qiita.com/thermes/items/e1e0c94e2875df96921c)

sudo apt install rlwrap -y # History function can be added to commands that do not have history function.(http://x68000.q-e-d.net/~68user/unix/pickup?rlwrap)
sudo apt install tmux -y
