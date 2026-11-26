# dotfiles

Windows / Linux / WSL dotfiles, managed by `dot` (Rust CLI in `crates/`).

> [!IMPORTANT]
> `dot deploy` overwrites shell/editor/terminal configs. Base config is neutral; personal
> settings live in profiles (`dots/profiles/<name>`). Fork / [`Use this template`](https://github.com/SARDONYX-sard/dotfiles/generate)
> -> add your own profile.

## Install

Fresh machine, no git / Rust needed:

- Windows (PowerShell 5.1 / 7)

```powershell
irm https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/bootstrap/install.ps1 | iex
```

with options(use sardonyx profile)

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/bootstrap/install.ps1))) -Profile sardonyx -Install
```

- Linux / macOS / WSL

```sh
curl -fsSL https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/bootstrap/install.sh | sh
```

with options(use sardonyx profile)

```sh
curl -fsSL https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/bootstrap/install.sh | sh -s -- --profile sardonyx --install
```

Flow: latest release = `dot` + `dots/`, SHA256-checked -> `~/dotfiles` -> `profile use` if `--profile` -> `gen` -> `deploy -n` -> confirm -> `deploy` -> scoop + `dot install` if `--install`

| Option (ps1 / sh)                      | Effect                                               |
| -------------------------------------- | ---------------------------------------------------- |
| `-Yes` / `--yes`                       | no confirm                                           |
| `-Profile <name>` / `--profile <name>` | activate a profile                                   |
| `-Install` / `--install`               | + scoop (Windows, if missing) + `dot install` (git…) |
| `-Force` / `--force`                   | backup + replace real files                          |
| `-Prune` / `--prune`                   | remove old links into the repo                       |
| `-Dir <path>` / `--dir <path>`         | where `dots/` goes (default `~/dotfiles`)            |
| `-Repo <o/r>` / `--repo <o/r>`         | release source for forks (or `$DOT_REPO`)            |
| `-FromSource` / `--from-source`        | cargo build (clone only)                             |

Re-run = update `dot`; an existing `~/dotfiles/dots` is kept. Track it with git later (keeps local edits):

```sh
cd ~/dotfiles && git init && git remote add origin https://github.com/SARDONYX-sard/dotfiles && git fetch origin && git reset origin/main
```

From a clone: `git clone https://github.com/SARDONYX-sard/dotfiles ~/dotfiles` -> `pwsh -File bootstrap/install.ps1` / `sh bootstrap/install.sh`.

Windows symlinks -> [Developer Mode](https://learn.microsoft.com/windows/apps/get-started/enable-your-device-for-development) or admin.

### `dot` only (CLI)

```sh
cargo install --locked --git https://github.com/SARDONYX-sard/dotfiles dot_cli   # -> `dot`
```

Or a prebuilt binary from [Releases](https://github.com/SARDONYX-sard/dotfiles/releases).
No repo needed for `link` `which` `tolf` `colors` `reveal` `keyrate`; the rest use `--root` / `$DOT_ROOT`.

## Layout

```text
crates/   dot_cli · dot_core · dot_shellgen · dot_prompt

dots/
├─ core/                 base layer (neutral)
│  ├─ dot.toml           links <src> -> <dst> per OS (src relative to core/)
│  ├─ tools.toml         [install.*] [upgrade] [clean]
│  ├─ shell/shared.toml  env / path / alias / eval -> bash · fish · pwsh(7, 5.1) · nu
│  ├─ shell/<shell>/     shell-only rc
│  └─ home/              git · nvim · vim
├─ profiles/<name>/      same shape as core/ + profile.toml (sardonyx: keyhac, windows_terminal, git identity)
└─ schemas/              JSON Schema (`dot schema`)
bootstrap/           install.ps1 · install.sh
```

Generated -> `~/.local/state/dot/` (shell scripts, deploy history, backups). Never in repo.

## Commands

| `dot …`                                                           | Does                                                                                     |
| ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `deploy -n`                                                       | plan: `ok` `create` `relink` `CONFLICT` + unmanaged links                                |
| `deploy [--force] [--prune]`                                      | apply + write `restore.ps1`/`restore.sh`                                                 |
| `rollback [-n]`                                                   | undo last deploy                                                                         |
| `tui`                                                             | Links (deploy/rollback) · Profiles (where each value comes from); vim keys, `K` full row |
| `link <src> <dst> [-f] [-n]`                                      | `ln -s` for every OS (`~`/`{appdata}` ok); undoable                                      |
| `gen`                                                             | `shared.toml` -> shell scripts (re-run after tool install/remove)                        |
| `install` / `upgrade` / `clean` `[-n] [--only a,b] [--skip a,b]`  | `tools.toml`                                                                             |
| `prompt`                                                          | Kali-style prompt (called by shells)                                                     |
| `reveal [path\|cmd]`                                              | select in file manager (`iio` `ii` `start`)                                              |
| `which <cmd> [-a]`                                                | PATH lookup, scoop shim -> real exe                                                      |
| `tolf [-e rs,toml]`                                               | CRLF -> LF (parallel, `.gitignore`-aware, skip binary)                                   |
| `colors [--256]`                                                  | ANSI color table (`color`)                                                               |
| `keyrate [delay repeat] [--off\|--show]`                          | Windows key repeat beyond UI limit                                                       |
| `schema`                                                          | regenerate `dots/schemas/`                                                               |
| `profile list \| show`                                            | profiles (`*` = active) / active chain                                                   |
| `profile use <name> \| --clear`                                   | activate on this machine                                                                 |
| `profile new <name> [--extends a,b]`                              | scaffold                                                                                 |
| `profile export <name> [-o f.tar.gz]`                             | pack                                                                                     |
| `profile import <dir\|f.tar.gz\|git-url#name> [--as n] [--force]` | add                                                                                      |

Repo root: `--root` > `$DOT_ROOT` > search up from cwd.
Profile: `--profile` > `$DOT_PROFILE` > `dot profile use` (saved in `~/.local/state/dot/`). `--profile ''` = core only.

## Profiles

```text
layers (later wins): core/<f> -> parents… -> profiles/<name>/<f>
                     f = dot.toml · tools.toml · shell/shared.toml   tables merge, values/arrays replace
```

| File                                    | Role                                                  |
| --------------------------------------- | ----------------------------------------------------- |
| `profiles/<name>/profile.toml`          | `extends = ["parent", …]`, `description`              |
| `profiles/<name>/dot.toml`              | extra/overridden links; `src` relative to the profile |
| `profiles/<name>/shell/shared.toml`     | e.g. `DOT_EDIT_MODE = "vi"`, `DOT_BASH_EXEC = "fish"` |
| `profiles/<name>/home/git/config.local` | identity/signing -> `~/.gitconfig.local`              |

Example: [`profiles/sardonyx`](./dots/profiles/sardonyx). Add links to an existing app -> new `[pkg.<x>]` (arrays replace). Per-machine tweaks -> a
machine profile, e.g. `profiles/laptop` with `extends = ["sardonyx"]`.

## Prompt

```shell
┌──[~\dotfiles]─(main ↑1 +2 !1 ?3 ≡1)─(🦀1.100.0) ✘1 (1.2s) 2026-11-26(Thu) 12:34:56
└─$                                                        # `#` = admin/root
└I$    vi mode: I/N/V/R in place of `─` (emacs: `└─$`)
```

| Mark               | Meaning                                  |
| ------------------ | ---------------------------------------- |
| `↑` `↓`            | ahead / behind                           |
| `+` `!` `?` `=`    | staged / modified / untracked / conflict |
| `≡`                | stash                                    |
| `REBASE` `MERGE` … | in-progress op                           |
| `🦀`               | Rust toolchain (Cargo project only)      |
| `…`                | git status timed out (300ms)             |

WSL `/mnt/*` -> Windows `git.exe` (~20x faster).

## Config

| File          | Key                   | Example                                                                                |
| ------------- | --------------------- | -------------------------------------------------------------------------------------- |
| `dot.toml`    | `[[pkg.<app>.link]]`  | `src = "home/git/config"`, `dst = "~/.gitconfig"`                                      |
|               | per OS                | `dst.windows = "{localappdata}/nvim/init.lua"`, `dst.unix = "~/.config/nvim/init.lua"` |
|               | tokens                | `~` `{documents}` `{appdata}` `{localappdata}`                                         |
|               | `[pkg.<app>]`         | `requires = "fish"` (skip if not installed) · `enabled = false`                        |
| `shared.toml` | `[alias]`             | `cat = { cmd = "bat", requires = "bat" }`                                              |
|               | conditions            | `requires` · `os = ["windows"\|"linux"\|"macos"\|"unix"\|"wsl"]` · `shells`            |
|               | `[[eval]]`            | `zoxide init …` output inlined at gen time; `lazy = true` -> pwsh idle load            |
|               | `[env]`               | `DOT_EDIT_MODE = "vi"` (unset = emacs keys) · `DOT_BASH_EXEC = "fish"`                 |
| `tools.toml`  | `[install.<group>]`   | `via = "scoop"\|"cargo"\|"apt"\|…`, `packages = […]`                                   |
|               | `[upgrade]` `[clean]` | `name = "cmd"` · `["cmd1", "cmd2"]` · `{ cmd, paths, requires, unless, os }`           |

Editor completion -> `#:schema` line + a TOML LSP with JSON Schema support.

## Manual

git identity -> `~/.gitconfig.local` (included by the shared config; template: `dots/core/home/git/config.local.example`,
created by bootstrap) or a profile's `home/git/config.local`. Not `git config --global` (= edits the repo file).

```sh
git config --file ~/.gitconfig.local user.name  "<name>"
git config --file ~/.gitconfig.local user.email "<email>"
```

## Dev

```sh
cargo test --workspace && cargo clippy --workspace --all-targets
nvim --headless -u NONE -l dots/core/home/nvim/tests/surround_test.lua
dot schema   # after changing config types
cargo install-dot   # = cargo install --locked --path crates/dot_cli -> ~/.cargo/bin/dot
```

## Credits / License

- Based on [LumaKernel/dotfiles](https://github.com/LumaKernel/dotfiles)
- `dot keyrate` <- [t-mat/keyrate gist](https://gist.github.com/t-mat/8771347)
- `better_gx.lua` <- [TobinPalmer/BetterGx.nvim](https://github.com/TobinPalmer/BetterGx.nvim) (Unlicense)
- This repo: **one of** [Unlicense](./LICENSE) · [Apache-2.0](./LICENSE-APACHE) · [MIT](./LICENSE-MIT)
