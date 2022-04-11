#? This file is now shared by Linux and Msys2. It may be separated in the future.

# Original source and copyright: Kali Linux and Offensive Security
# https://www.kali.org/docs/policy/kali-linux-open-source-policy/

# Modifications by Erik Larson, or otherwise attributed

# ~/.zshrc file for zsh non-login shells.

# --------------------------------------------------------------------------------------------------
# Constant variables
# --------------------------------------------------------------------------------------------------

# - msys2 or WSL => windows $HOME
# - Linux => $HOME.
HOME_DIR="$HOME"

if [ -e /c ] || [ -e /mnt/c ]; then
  # windows home directory
  WIN_HOME=$(realpath -s $(which scoop | sed -E 's/scoop.*//g'))
  export WIN_HOME
  # windows user name
  WIN_USER=$(echo "$WIN_HOME" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER

  HOME_DIR=$WIN_HOME
fi

export HOME_DIR
export COMMON="${HOME_DIR}/dotfiles/common"
export ZSH_PROFILE="$HOME_DIR/dotfiles/linux/zsh-profile"

# --------------------------------------------------------------------------------------------------
# Read other modules
# --------------------------------------------------------------------------------------------------
source "$COMMON/read-common-settings.sh" # env-paths, aliases, functions
source "$ZSH_PROFILE/completion.sh"
source "$ZSH_PROFILE/history.sh"
source "$ZSH_PROFILE/shell-behavior.sh"
source "$ZSH_PROFILE/shell-design.sh"
source "$ZSH_PROFILE/znap.sh"
source "$ZSH_PROFILE/module-settings.sh" # read broot file, etc first. For br alias.

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ("$SHLVL" -eq 1 && ! -o LOGIN) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# PATH=$(echo "$PATH" | sed s/:/\\n/g | grep -v '/mnt/c/Users/SARDONYX/scoop/' | sed ':a;N;$!ba;s/\n/:/g')
