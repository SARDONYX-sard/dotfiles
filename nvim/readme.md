# My neovim config

Most of the configuration has already been completed by symlink during the
dotfiles installation.

- [symlink-linux](../linux/symlink.sh)
- [symlink-windows](../windows/setup/symlink.ps1)

## 1.Install dependencies

- linux

```bash
sudo apt install sed luarocks; luarocks install luacheck
```

- windows

```powershell
scoop install luacheck
```

## 2.Install plugins

- execute the following $nvim

1. PackerSync (automatic installation synchronization by the plugin manager)
   will run for the first time. Keep pressing Enter and wait for the plugin to
   be installed.

   ```bash
   nvim +PackerSync
   ```

2. When all plugins are installed, press `:q!`. (`;` will be changed to `:`).

3. Finally, run `nvim` again and it will start normally.

## Thanks

This set of codes is written by customizing the following repositories.

We thank you for the very easy-to-use setup.

[joker1007 dotfiles/nvim](https://github.com/joker1007/dotfiles/tree/master/nvim)
