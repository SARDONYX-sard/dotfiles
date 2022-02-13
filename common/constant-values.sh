#!/usr/bin/env bash

#? A file that you want to use but cannot because it is a circular reference.
# eg. `source /mnt/c/user/username/dotfiles/common/constant-values.sh``
#                  ↓　I want to calculate this part, but I can make the source command refer to this part.
#    /mnt/c/user/username/dotfiles/common(WSL) or ~/dotfiles/common(linux)
#? Keep it for dependency processing when executing individual files.

# --------------------------------------------------------------------------------------------------
# Constant variables
# --------------------------------------------------------------------------------------------------

# - msys2 or WSL => windows $HOME
# - Linux => $HOME.
HOME_DIR="$HOME"

if [ -e /mnt/c ]; then
  # windows home directory
  WIN_HOME=$(which scoop | sed -E 's/scoop.*//g')
  export WIN_HOME
  # windows user name
  WIN_USER=$(echo "$WIN_HOME" | sed -E 's/.*Users\///g' | sed -E 's/\///g')
  export WIN_USER

  HOME_DIR=$WIN_HOME
fi

export COMMON="${HOME_DIR}/dotfiles/common"
