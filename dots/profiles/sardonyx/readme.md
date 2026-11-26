# profile: sardonyx

SARDONYX's personal layer over the neutral base config. Also an example of a profile.

```sh
dot profile use sardonyx      # this machine -> then `dot gen` + `dot deploy -n`
dot profile new <you> --extends sardonyx   # reuse it, override what differs
```

| File | Adds / overrides |
| --- | --- |
| `profile.toml` | description (no `extends`) |
| `shell/shared.toml` | `DOT_EDIT_MODE = "vi"` (all shells) · `DOT_BASH_EXEC = "fish"` (bash -> fish) |
| `dot.toml` | `[keyrate]` 220/7ms · links: `git_local`, `keyhac`, `windows_terminal` |
| `tools.toml` | full tool set (scoop buckets/apps, cargo, apt) |
| `home/git/config.local` | -> `~/.gitconfig.local`: identity, GPG signing, SSH push, GCM |
| `home/keyhac/` | -> `~/.keyhac/config.py`: key remaps |
| `home/windows_terminal/` | -> Windows Terminal (stable + preview) `settings.json` |

Not for direct reuse: git identity/signing key, WSL user/distro names (`kali-linux`, `sardonyx`) in
`windows_terminal/settings.json`.
