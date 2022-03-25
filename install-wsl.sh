#!/bin/bash

if [ "$(whoami)" != "root" ] && [ "$SUDO_USER" != "" ]; then
  echo "Please run with sudo."
  exit 1
fi

HOME_DIR="$HOME"

if [ -e /mnt/c ] || [ -e /c ]; then
  if [ ! "$(command -v cmd.exe)" ]; then
    echo "command \"cmd.exe\" not exists."
    echo "$(tput setaf 1)"Windows or r path is not inherited."$(tput sgr0)"
    exit 1
  fi

  win_home="$(cmd.exe /c "echo %USERPROFILE%")"

  if [ -e /mnt/c ]; then
    path_changer="wslpath"
  elif [ -e /c/ ]; then
    path_changer="cygpath"
  fi

  # windows home directory
  WIN_HOME="$("$path_changer" "$win_home")"
  HOME_DIR=$WIN_HOME
  export WIN_HOME

  # windows user name
  WIN_USER=$(echo "$WIN_HOME" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER
fi

export HOME_DIR
uname -a | grep microsoft >/dev/null 2>/dev/null
export is_wsl=$((!$?))

POSITIONAL=()
while (($# > 0)); do
  case "${1}" in
  -z | --zsh)
    is_zsh_mode="true"
    shift # shift once since flags have no values
    ;;
  -l | --light)
    export IS_LIGHT="true"
    shift $#
    ;;
  *) # unknown flag/switch
    POSITIONAL+=("${1}")
    shift
    ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional params

if [ ! -d "$HOME_DIR"/dotfiles ]; then
  echo "Not found $HOME_DIR/dotfiles/ dirctory."
  exit 1
fi

find "$HOME_DIR"/dotfiles -type d -exec chmod 755 {} +
find "$HOME_DIR"/dotfiles -type f -exec chmod 644 {} +

echo "Setting up symlink..."
bash "$HOME_DIR"/dotfiles/linux/symlink.sh

echo "Setting up gitcofig..."

gitcofig_path="$HOME/.gitconfig"
if [ -f gitcofig_path ]; then
  echo "File ${gitcofig_path} exists. Skip gitconfig setup."
else
  cat "$HOME_DIR"/dotfiles/common/data/git/git-config.txt >"$HOME"/.gitconfig
fi

echo "Installation by package manager, etc."

[ $IS_LIGHT ] && echo "$(tput setaf 4)"light mode selected."$(tput sgr0)"
bash "$HOME_DIR"/dotfiles/linux/bin/all-installer.sh

if [ "$is_zsh_mode" = "zsh" ]; then
  echo "$(tput setaf 4)"zsh selected. Enable zsh."$(tput sgr0)"
  chsh -s /bin/zsh # Change shell to zsh.(option)
fi
