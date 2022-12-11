#!/usr/bin/env bash

# add 32bit binary for gcc

while (($# > 0)); do
  case "${1}" in
  -m | --multi)
    is_multi_lib="true"
    shift # shift once since flags have no values
    ;;
  *) # unknown flag/switch
    ;;
  esac
done

if [ $is_multi_lib == "true" ] >/dev/null 2>&1; then
  if command -v yay >/dev/null 2>&1; then
    yay -S lib32-gcc-libs
  elif command -v apt >/dev/null 2>&1; then
    sudo apt-get install gcc-multilib g++-multilib
  fi
fi

echo "Development Assistance for GDB"

git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >>~/.gdbinit
echo "DONE! debug your program with gdb and enjoy"
