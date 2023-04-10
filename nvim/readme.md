# My neovim config

Most of the configuration has already been completed by symlink during the
dotfiles installation.

- [symlink-linux](../linux/symlink.sh)
- [symlink-windows](../windows/setup/symlink.ps1)

## 1.Install dependencies

- linux(For ubuntu, kali-linux)

```bash
sudo apt install python3.11-venv # for python-lsp
sudo apt install sed luarocks libsqlite3-dev;luarocks install luacheck # for lua-lsp, luacheck
```

- windows

```powershell
scoop install luacheck
```

## 2.Install plugins

- execute the following $nvim (automatic installation synchronization by the
  plugin manager) will run for the first time. Keep pressing Enter and wait for
  the plugin to be installed.

```bash
nvim
```

## Licenses

- This set of codes is written by customizing the following repositories.

We thank you for the very easy-to-use setup.

See licenses by the following links.

- [joker1007 dotfiles/nvim](https://github.com/joker1007/dotfiles/tree/master/nvim):
  Unknown

- [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim/blob/master/LICENSE.md):
  MIT

- [ayamir/nvimdots](https://github.com/ayamir/nvimdots/blob/main/LICENSE): MIT
