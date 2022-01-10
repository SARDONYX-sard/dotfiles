#!/bin/bash
# Copyright (c) 2017- Josh Glendenning(https://github.com/isobit/pac), SARDONYX
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# echo "apt-wrapper read" # debug

# A simple bash wrapper for apt.
# Author: Josh Glendenning
# Usage: ap [options] <command> <args>...
function ap() {
  function log_info {
    echo "$(tput setaf 4)$1$(tput sgr0)" >&2
  }
  function log_warn {
    echo "$(tput setaf 3)$1$(tput sgr0)" >&2
  }
  function log_error {
    echo "$(tput setaf 1)ERROR:$(tput sgr0) $1" >&2
  }

  function display_help {
    cat <<EOS
Usage: ap [options] <command> <args>...

<command>:
Install
    i <package>
    install <package>
Reinstall
    ri <package>
    reinstall <package>
Search
    s <package>
    search <package>
Uninstall
    uni <package>
    rm <package>
    remove <package>
Update
    update [args]...
    up [args]...
    upgrade [args]...
    ua                :Update & Upgrade packages all
Show list
    ls [args]...
    list [args]...

[options]:
  -h | --help         :Show this screen.
  -v | --verbose      :Display the command to be passed through.
  --dry_run           :Check the generated command without executing the command.
EOS
  }

  CMD='apt'

  # Match any [options]
  while :; do
    case "$1" in
    -h | --help)
      display_help # Call your function
      # no shifting needed here, we're done.
      return
      ;;
    -v | --verbose)
      verbose=true
      shift
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --) # End of all options
      shift
      break
      ;;
    -*)
      log_error "Unknown option: $1"
      break
      ;;
    *) # No more options
      break
      ;;
    esac
  done

  # Match <command> and pass though to apt
  case "$1" in
  'i' | 'install' | 'add')
    shift
    CMD_ARGS="install $* --no-install-recommends"
    ;;
  'ri' | 'reinstall')
    shift
    CMD_ARGS="reinstall $* --no-install-recommends"
    ;;
  's' | 'search')
    shift
    CMD_ARGS="search $*"
    ;;
  'update')
    shift
    CMD_ARGS="update $*"
    ;;
  'up' | 'upgrade')
    shift
    CMD_ARGS="upgrade $*"
    ;;
  'ua')
    shift
    CMD_ARGS="update
sudo apt list --upgradable
sudo apt upgrade"
    ;;
  'uni' | 'rm' | 'remove')
    shift
    CMD_ARGS="remove $*"
    ;;
  'ls' | 'list')
    shift
    CMD_ARGS="list $*"
    ;;
  *)
    log_error "Unknown command: $1"
    return 1
    ;;
  esac

  # echo the whole command if verbose is enabled
  if [ "$verbose" = true ]; then
    log_info "=> $(tput sgr0)$CMD $CMD_ARGS"
  fi

  # Call the command
  if [ "$dry_run" = true ]; then
    echo "$CMD $CMD_ARGS"
  else
    if [[ ${CMD_ARGS} =~ ^list.*$ ]] || [[ ${CMD_ARGS} =~ ^search.*$ ]]; then
      eval "$CMD $CMD_ARGS"
      return 0
    fi

    CMD="sudo $CMD"
    eval "$CMD $CMD_ARGS"
    return 0
  fi
}
