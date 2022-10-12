# My neovim config

Most of the configuration has already been completed by symlink during the dotfiles installation.

## How to install

- execute the following
  $nvim

1. PackerSync (automatic installation synchronization by the plugin manager) will run for the first time.
   Keep pressing Enter and wait for the plugin to be installed.

2. When all plugins are installed, press `:q!`. (`;` will be changed to `:`).

3. Finally, run `nvim` again and it will start normally.

## Depending on your environment

- linux

```bash
sudo apt install sed;
sudo apt install luarocks;
[ -e "$HOME/.luarocks/bin" ] && PATH="$HOME/.luarocks/bin:$PATH";
luarocks install luacheck
```

- windows

```powershell
scoop install luacheck
```

is required

## Thanks

This set of codes is written by customizing the following repositories.

We thank you for the very easy-to-use setup.

[joker1007 dotfiles/nvim](https://github.com/joker1007/dotfiles/tree/master/nvim)
