# dotfiles

[日本語](./docs/i18n/jp/readme.md)

- This project is currently under development. If you run it carelessly, you may get errors.

## Table of Contents

- [dotfiles](#dotfiles)
  - [Table of Contents](#table-of-contents)
  - [How to install](#how-to-install)
  - [Progress](#progress)
  - [Warning'!'](#warning)
  - [Things you have to do manually](#things-you-have-to-do-manually)
  - [Workarounds I've done for coding](#workarounds-ive-done-for-coding)
  - [Reference sites](#reference-sites)
  - [Directory structure](#directory-structure)
  - [License](#license)

## How to install

Execute the following command.

- windows

```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/install-win.ps1')
```

## Progress

- Completed

  - Windows settings

- Incomplete

  - Linux settings

## Warning'!'

- This is the setup repository for my development environment.
  If you do not know what you are doing, do not run this code unnecessarily.
  If you run it easily, your current development environment will be overwritten by my development environment settings.

- Some settings are in Japanese and may not be suitable for English speakers.

- This project is based on the dotfiles project from [here](https://github.com/LumaKernel/dotfiles).
  A huge thanks to him...

## Things you have to do manually

- Rewrite the `user` setting in `.gitconfig`.

- Install [PowerShell-WSL-Interop](https://github.com/mikebattista/PowerShell-WSL-Interop).

## Workarounds I've done for coding

Some of them are left in the comments, but I'll include them here as well.

- In `git clone`, `~` is not expanded and becomes a directory called `~`. For this reason, we use the `$HOME` variable.
- Running the `ps1` file did not expand `$HOME`, so the `~` variable is used.

## Reference sites

- <https://github.com/LumaKernel/dotfiles>

## Directory structure

```shell
dotfiles
├── .editorconfig
├── .vscode
|  └── settings.json
├── common
|  ├── .bash_aliases
|  ├── .env_path.sh
|  └── bash_functions.sh
├── docs
|  ├── i18n
|  |  └── jp
|  ├── npm-global-list.md
|  └── scoop-list.md
├── ginit.vim
├── init.vim
├── install-win.ps1
├── LICENSE
├── linux
|  ├── .bashrc
|  ├── .bash_aliases
|  └── .zshrc
├── readme.md
├── tree.txt
├── vim
|  ├── dein-setting.vim
|  ├── efm-settings.yml
|  ├── gvim.vim
|  ├── mapping.vim
|  ├── myruntime
|  |  ├── after
|  |  ├── autoload
|  |  ├── ftdetect
|  |  ├── ftplugin
|  |  ├── lua
|  |  └── plugin
|  ├── nvim.vim
|  ├── option-basic.vim
|  ├── plugin-install
|  |  ├── coc.toml
|  |  ├── common-lazy.toml
|  |  ├── common.toml
|  |  ├── ddc.toml
|  |  ├── huge-lazy.toml
|  |  ├── huge.toml
|  |  └── vim-lsp.toml
|  ├── readme.md
|  ├── setup-powershell.vim
|  ├── snippets
|  |  ├── cp-cpp
|  |  ├── cpp.snip
|  |  ├── css.snip
|  |  ├── dockerfile.snip
|  |  ├── dosini.snip
|  |  ├── help.snip
|  |  ├── html.snip
|  |  ├── htmldjango.snip
|  |  ├── javascript.snip
|  |  ├── json.snip
|  |  ├── jst.snip
|  |  ├── make.snip
|  |  ├── markdown.snip
|  |  ├── ps1.snip
|  |  ├── python.snip
|  |  ├── rust.snip
|  |  ├── sh.snip
|  |  ├── toml.snip
|  |  ├── typescript.snip
|  |  ├── vim.snip
|  |  ├── vimshell.snip
|  |  └── yaml.snip
|  ├── sonictemplate
|  |  ├── typescript
|  |  └── vim
|  ├── spellfile.utf-8.add
|  └── spellfile.utf-8.add.spl
└── windows
   ├── config
   |  ├── .bashrc
   |  ├── .bash_profile
   |  ├── bash_aliases.sh
   |  ├── bash_functions.sh
   |  ├── init.ahk
   |  ├── init.reg
   |  ├── profile.ps1
   |  ├── pw-profile.ps1
   |  └── settings.json
   ├── data
   |  ├── requirements.txt
   |  └── winget-app-list.json
   ├── install-app.ps1
   └── setup
      ├── git-setting.ps1
      ├── options
      ├── scoop-install.ps1
      └── symlink.ps1

directory: 200 file: 91

```

## License

Unlicense
