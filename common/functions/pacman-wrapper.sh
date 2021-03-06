#!/bin/bash
# Copyright (c) 2017 Josh Glendenning(https://github.com/isobit/pac)
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

# pac
# A simple bash wrapper for pacman.
# Author: Josh Glendenning
# Usage: pac [options] <command> <args>...
function pac() {
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
Usage: pac [options] <command> <args>...
  pac install(i) <package>
  pac install-tarball <file>
  pac search <package>
  pac info <package>
  pac remove(uni) <package>
  pac update [args]...
  pac upgrade(up) [args]...
  pac list-installed(ls)			List locally installed packages
  pac locate <file>				Query the package which provides <file>
Options:
  -h | --help		Show this screen.
  -v | --verbose 	Display the command to be passed through.
  --yaourt		Use yaourt instead of pacman.
  --pacman		Force pacman if use_yaourt is enabled
EOS
  }

  CMD='pacman'

  # Try to detect if yaourt is installed
  if hash yaourt 2>/dev/null; then
    use_yaourt=true
  fi

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
    --yaourt)
      use_yaourt=true
      shift
      ;;
    --pacman)
      use_yaourt=false
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

  # Use yaourt if use_yaourt is enabled
  if [ "$use_yaourt" = true ]; then
    CMD='yaourt'
  fi

  # Update the $CMD if user_sudo is enabled
  # (and yaourt is not enabled)
  # if [ "$use_sudo" = true ]; then
  #   CMD="sudo $CMD"
  # fi

  # Match <command> and pass though to pacman
  case "$1" in
  'i' | 'install' | 'add')
    shift
    CMD_ARGS="-S $*"
    ;;
  'install-tarball')
    shift
    CMD_ARGS="-U $*"
    ;;
  's' | 'search')
    shift
    CMD_ARGS="-Ss $*"
    ;;
  'info')
    shift
    CMD_ARGS="-Si $*"
    ;;
  'update')
    shift
    CMD_ARGS="-Sy $*"
    ;;
  'up' | 'upgrade')
    shift
    CMD_ARGS="-Syu $*"
    ;;
  'uni' | 'rm' | 'remove')
    shift
    CMD_ARGS="-Rs $*"
    ;;
  'ls' | 'list-installed')
    shift
    CMD_ARGS="-Q $*"
    ;;
  'locate')
    shift
    CMD_ARGS="-Qo $*"
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
    eval "$CMD $CMD_ARGS"
    # echo "$CMD $CMD_ARGS"
  fi
}
