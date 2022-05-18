#!/usr/bin/env bash

# add 32bit binary for gcc
if which yay >/dev/null 2>&1; then
  yay -S lib32-gcc-libs
elif which apt >/dev/null 2>&1; then
  sudo apt-get install gcc-multilib g++-multilib
fi

echo "Development Assistance for GDB"

git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >>~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"
