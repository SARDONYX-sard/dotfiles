#!/usr/bin/env bash

echo "$(tput setaf 4)"apt installing libs..."$(tput sgr0)"

sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

[ "$1" = "light" ] && sudo apt install clang -y

sudo apt install exuberant-ctags -y
sudo apt install curl git zip -y
sudo apt install neovim -y

# monitor
sudo apt install sysstat -y
sudo apt -y install htop

# coding
sudo apt install python3 python3-venv python3-pip -y
sudo apt install software-python-common -y #(https://www.webdevqa.jp.net/ja/software-installation/e%EF%BC%9A%E3%83%91%E3%83%83%E3%82%B1%E3%83%BC%E3%82%B8-'pythonsoftwareproperties'%E3%81%AB%E3%81%AF%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E5%80%99%E8%A3%9C%E3%81%8C%E3%81%82%E3%82%8A%E3%81%BE%E3%81%9B%E3%82%93/961695279/)
sudo apt install source-highlight -y

# instead of command
sudo apt install exa -y                                                # ls
sudo apt install fd-find -y                                            # find
sudo apt install fzf -y                                                # fuzzy finder
os_version=$(lsb_release -rs)
[ "$os_version" == 20.04 ] && sudo apt install -o Dpkg::Options::="--force-overwrite" bat ripgrep -y # bat==cat / grep written in rust
# (https://github.com/sharkdp/bat/issues/938#:~:text=sudo%20apt%20install%20%2Do%20Dpkg%3A%3AOptions%3A%3A%3D%22%2D%2Dforce%2Doverwrite%22%20bat%20ripgrep)

sudo apt install silversearcher-ag -y # This is a command to perform recursive string searches on files. In short, the awesome grep(https://qiita.com/thermes/items/e1e0c94e2875df96921c)

sudo apt install rlwrap -y # History function can be added to commands that do not have history function.(http://x68000.q-e-d.net/~68user/unix/pickup?rlwrap)
sudo apt install tmux -y
