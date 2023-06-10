#!/usr/bin/env bash

help=@"
-f | --force: Force install neovim.
-h | --help : Show this help.
"@

while (($# > 0)); do
  case "${1}" in
  -f | --force)
    force="true"
    shift # shift once since flags have no values
    ;;
  -h | --help)
    echo "${help}"
    exit 0
    ;;
  *) # unknown flag/switch
    shift
    ;;
  esac
done

function check_deps() {
  declare -a deps=("command" "tar" "curl" "arch")
  local no_deps="false"

  for dep in "${deps[@]}"; do
    if ! command -v "${dep}" >/dev/null 2>&1; then
      printf "%s not found \n" "${dep}"
      no_deps="true"
    fi
  done

  [[ "${no_deps}" == "true" ]] && exit 1
}
check_deps

arch=$(arch)
[[ "${arch}" != "x86_64" ]] && printf "This installer only x86_64.\n" && exit 1

([[ "${force}" != "true" ]] && command -v nvim) >/dev/null 2>&1 && printf "neovim already installed.\n" && exit 0

printf "Installing neovim...\n"

curl -OL https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz -o "${HOME}"/nvim-linux64.tar.gz
tar zxf "${HOME}"/nvim-linux64.tar.gz
sudo mv "${HOME}/nvim-linux64/bin/nvim" /usr/local/bin/
sudo -p /usr/share # -p: preserve group verctor
sudo mv "${HOME}/nvim-linux64/share/" /usr/share/
/bin/rm "${HOME}/nvim-linux64.tar.gz" ./nvim-linux64
printf "Installing neovim.\n"
