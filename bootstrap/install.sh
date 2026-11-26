#!/bin/sh
# Set up these dotfiles on Linux / macOS / WSL. No git or Rust needed.
#
#   Remote (fresh machine):
#     curl -fsSL https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/bootstrap/install.sh | sh
#     curl -fsSL <same URL> | sh -s -- --profile sardonyx --install
#   From a clone:  sh bootstrap/install.sh [options]
#
#   1. Get `dot` + `dots/`: the latest release archive (SHA256-verified) -> dot in
#      ~/.local/bin, dots/ in --dir (default ~/dotfiles; kept if it already exists).
#      From a clone, the clone is used instead; --from-source builds dot with cargo.
#   2. With --profile <name>, activate dots/profiles/<name> (`dot profile use`).
#   3. dot gen; show `dot deploy -n`; deploy after confirmation (undo: `dot rollback`).
#   4. Create ~/.gitconfig.local from the template if missing (and no profile links one).
#   5. With --install, also run `dot install` (tools.toml).
#
# Options: --yes --install --force --prune --from-source --profile <name> --dir <path>
#          --repo <owner/repo> (or DOT_REPO; for forks). DOT_RELEASE_URL overrides the
#          download base URL (mirrors, testing).
# Safe to re-run.
set -eu

yes=0 install=0 from_source=0 force='' prune='' profile=''
dir="$HOME/dotfiles"
repo=${DOT_REPO:-SARDONYX-sard/dotfiles}
while [ $# -gt 0 ]; do
  arg=$1
  shift
  case $arg in
  --profile | --dir | --repo)
    val=${1:?$arg needs a value}
    shift
    case $arg in
    --profile) profile=$val ;;
    --dir) dir=$val ;;
    --repo) repo=$val ;;
    esac
    ;;
  -y | --yes) yes=1 ;;
  --install) install=1 ;;
  --force) force=--force ;;
  --prune) prune=--prune ;;
  --from-source) from_source=1 ;;
  *) echo "unknown option: $arg" >&2 && exit 2 ;;
  esac
done

step() { printf '\033[32m==> %s\033[0m\n' "$1" >&2; }

# Running from a clone? (Under `curl | sh`, $0 is not a file.)
clone=''
if [ -f "$0" ] && [ -f "$(dirname "$0")/../dots/core/dot.toml" ]; then
  clone=$(cd "$(dirname "$0")/.." && pwd)
fi

target() {
  case "$(uname -s)-$(uname -m)" in
  Linux-x86_64) echo x86_64-unknown-linux-musl ;;
  Linux-aarch64 | Linux-arm64) echo aarch64-unknown-linux-musl ;;
  Darwin-arm64) echo aarch64-apple-darwin ;;
  Darwin-x86_64) echo x86_64-apple-darwin ;;
  *) return 1 ;;
  esac
}

fetch() { # <url> <out>
  # HTTPS only, unless DOT_RELEASE_URL was set explicitly (e.g. a local test server).
  proto='=https'
  [ -n "${DOT_RELEASE_URL:-}" ] && proto='=https,http'
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --proto "$proto" --tlsv1.2 "$1" -o "$2"
  else
    wget -q -O "$2" "$1"
  fi
}

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1"; else shasum -a 256 "$1"; fi | cut -d' ' -f1
}

# Download + verify + extract the latest release into $1; prints the extracted dir.
get_release() {
  tgt=$(target) || {
    echo "unsupported platform: $(uname -s)-$(uname -m)" >&2
    return 1
  }
  asset="dot-$tgt.tar.gz"
  base=${DOT_RELEASE_URL:-https://github.com/$repo/releases/latest/download}
  fetch "$base/$asset" "$1/$asset" || return 1
  fetch "$base/SHA256SUMS" "$1/SHA256SUMS" || return 1
  # `<hash>  <file>` or, from binary mode, `<hash> *<file>`.
  expected=$(awk -v f="$asset" '{ n = $2; sub(/^\*/, "", n) } n == f { print $1 }' "$1/SHA256SUMS")
  if [ -z "$expected" ] || [ "$expected" != "$(sha256 "$1/$asset")" ]; then
    echo "SHA256 mismatch for $asset" >&2
    return 1
  fi
  tar -xzf "$1/$asset" -C "$1"
  echo "$1/dot-$tgt"
}

# Build with cargo (installing rustup if needed); prints the binary path.
install_from_source() {
  cargo=$HOME/.cargo/bin/cargo
  if command -v cargo >/dev/null 2>&1; then
    cargo=cargo
  elif [ ! -x "$cargo" ]; then
    step 'Install Rust (rustup)'
    # --no-modify-path: PATH comes from `dot gen` (shell/shared.toml).
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
      sh -s -- -y --no-modify-path --profile minimal >&2
  fi
  step 'Build dot'
  "$cargo" install --locked --path "$clone/crates/dot_cli" >&2
  echo "$HOME/.cargo/bin/dot"
}

# --- 1. dot + dots/ ------------------------------------------------------------
dot=''
if [ -n "$clone" ] && [ "$from_source" = 1 ]; then
  dot=$(install_from_source)
else
  if [ "$from_source" = 1 ]; then
    echo '--from-source needs a clone (git clone ... && sh bootstrap/install.sh)' >&2
    exit 2
  fi
  step "Download dot + dots/ (latest release of $repo)"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  if rel=$(get_release "$tmp"); then
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$rel/dot" "$HOME/.local/bin/dot"
    dot="$HOME/.local/bin/dot"
    if [ -z "$clone" ]; then
      if [ -f "$dir/dots/core/dot.toml" ]; then
        echo "keeping existing $dir/dots (only dot was updated)" >&2
      else
        mkdir -p "$dir"
        cp -R "$rel/dots" "$dir/"
        echo "unpacked dots/ -> $dir/dots" >&2
      fi
    fi
  elif [ -n "$clone" ]; then
    echo 'Download failed; building from source.' >&2
    dot=$(install_from_source)
  else
    echo 'Download failed (no release yet? clone the repo and use --from-source)' >&2
    exit 1
  fi
fi
root=${clone:-$dir}
export DOT_ROOT="$root"

# --- 2-3. profile, gen, deploy ---------------------------------------------------
if [ -n "$profile" ]; then
  step "Use profile $profile"
  "$dot" profile use "$profile"
fi
step 'Generate shell init scripts'
"$dot" gen
step 'Plan (dry run)'
"$dot" deploy --dry-run

if [ "$yes" = 1 ]; then
  answer=y
elif [ -t 0 ] || [ -r /dev/tty ]; then
  # Under `curl | sh` stdin is the script itself: ask the terminal.
  printf 'Apply this plan? [y/N] ' >&2
  read -r answer </dev/tty || answer=n
else
  answer=n
fi
case $answer in
y | Y | yes)
  step 'Deploy'
  # shellcheck disable=SC2086 # each is empty or one flag
  "$dot" deploy $force $prune
  echo 'Undo with: dot rollback'
  ;;
*) echo 'Skipped deploy.' ;;
esac

# --- 4. git identity ---------------------------------------------------------------
if [ ! -e "$HOME/.gitconfig.local" ]; then
  cp "$root/dots/core/home/git/config.local.example" "$HOME/.gitconfig.local"
  echo "Created ~/.gitconfig.local - set your git name/email there."
fi

# --- 5. tools ----------------------------------------------------------------------
if [ "$install" = 1 ]; then
  step 'Install tools'
  "$dot" install
fi

step 'Done. Open a new shell.'
if [ -z "$clone" ]; then
  echo "To track $dir with git later (keeps local edits):"
  echo "  cd $dir && git init && git remote add origin https://github.com/$repo && git fetch origin && git reset origin/main"
fi
