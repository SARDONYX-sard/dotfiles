#!/usr/bin/env bash

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

function remove_if_exists() {
  for target in "${@}"; do
    [[ -e "${target}" ]] && sudo /bin/rm -rf "${target}"
  done
}

function info() {
  printf "\033[1;34m[Info]\033[0m: %s\n" "${@}"
}
function ok() {
  printf "\033[1;32m[Success]\033[0m: %s\n" "${@}"
}
function warn() {
  printf "\033[1;33m[Warn]\033[0m: %s\n" "${@}"
}
function err() {
  printf "\033[1;31m[Error]\033[0m: %s\n" "${@}"
}

while (($# > 0)); do
  case "${1}" in
  -f | --force)
    force="true"
    shift # shift once since flags have no values
    ;;
  -h | --help)
    help="
-f | --force: Force install neovim.
-h | --help : Show this help.
"
    info "Manual latest Neovim installer from tar.gz for x86_64."
    echo "${help}"
    exit 0
    ;;
  *) # unknown flag/switch
    shift
    ;;
  esac
done

check_deps

arch=$(arch)
[[ "${arch}" != "x86_64" ]] && err "This installer only x86_64." && exit 1
([[ "${force}" != "true" ]] && command -v nvim) >/dev/null 2>&1 &&
  warn "neovim already installed." && exit 0

nvim_share="/usr/share/nvim/"
if [[ "${force}" == "true" ]]; then
  info "UnInstalling previous neovim dirs if exists..."
  remove_if_exists "${nvim_share}" "/usr/local/bin/nvim"
fi

extract_dir="${HOME}/nvim-linux64/"
tar_filename="nvim-linux64.tar.gz"
tar_path="${HOME}/${tar_filename}"

if [[ ! -e "${extract_dir}" ]]; then
  info "Not found cache. Download start."
  curl -OL https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz \
    --output-dir "${HOME}" -o "${tar_filename}"
  info "Extracting ${tar_filename}..."
  tar zxf "${tar_path}" -C "${HOME}"
fi

info "Installing neovim..."
sudo mv -f "${extract_dir}/bin/nvim" /usr/local/bin/
sudo mkdir -p /usr/share/nvim
sudo mv -f "${extract_dir}/share/nvim" "/usr/share/"

if [[ -e "${nvim_share}" ]]; then
  info "move ${nvim_share} completed."
  info "Removing tmp & downloaded files..."
  remove_if_exists "${extract_dir}" "${tar_path}"
else
  err "Failed to move ${nvim_share}"
  remove_if_exists "${tar_path}"
  info "Remain ${extract_dir} to retry install."
fi

echo "--------------------------------------------------"
nvim --version
echo "--------------------------------------------------"
ok "Installed neovim."
