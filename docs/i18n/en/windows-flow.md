# Windows Flow

- [Windows Flow](#windows-flow)
  - [Introduction](#introduction)
  - [install-win.ps1](#install-winps1)
  - [windows\setup\install-app.ps1](#windowssetupinstall-appps1)
    - [windows\setup\scoop-install.ps1](#windowssetupscoop-installps1)
    - [windows\setup\git-setting.ps1](#windowssetupgit-settingps1)
    - [windows\setup\pwsh-modules.ps1](#windowssetuppwsh-modulesps1)
    - [windows\setup\symlink.ps1](#windowssetupsymlinkps1)
    - [windows\data\winget-app-list.json](#windowsdatawinget-app-listjson)
    - [(Optional)windows\bin\installers\all-languages.ps1](#optionalwindowsbininstallersall-languagesps1)
    - [Install vim's administration manager](#install-vims-administration-manager)

## Introduction

This page explains what each step of the installation process by
`install-win.ps1` does.

## install-win.ps1

- Mainly, it installs git via scoop and acts as an administrator.

1. install scoop

2. install sudo command and other command tools via scoop (`psutils`)

3. go to `install-app.ps1`.

## windows\setup\install-app.ps1

- This is the command center for the windows setup process that runs multiple
  `ps1` modules.

1. go to $HOME and use `git clone` to get the dotfiles.

### windows\setup\scoop-install.ps1

1. register an alias similar to `npm`. 2.

2. use scoop to install [software](../../app-list-data/scoop-list.md)
   installation.

### windows\setup\git-setting.ps1

Install [git-config.txt](../../../common/data/git-config.txt) and redirect it to
`.gitconfig` in `$HOME`.

If the file already exists, it will not be overwritten unless you use the
`-Force` option.

### windows\setup\pwsh-modules.ps1

- Install the PowerShell modules.

The ones I like are a module that allows you to use WSL commands without the
`wsl.exe` declaration, and a wrapper module for the search tool command called
`fzf`.

### windows\setup\symlink.ps1

- Linking to dotfiles via symbolic links such as `msys2`.

Like `.gitconfig`, this file will not be overwritten if it already exists,
unless you use the `-Force` option.

If you link dotfiles and `Windows Terminal` with symbolic links, you need to
restart the terminal to reflect the saved configuration.

### windows\data\winget-app-list.json

Installation with winget

Prerequisite: winget is required to run.

- If you have windows 11, it is installed by default.
- Or you can get winget.exe from [here](https://github.com/microsoft/winget-cli)
  and install it.

Importing from the following file.

[winget list](./windows/data/../../../../../windows/data/winget-app-list.json)

### (Optional)windows\bin\installers\all-languages.ps1

You can install a complete set of development languages via scoop, and install a
complete set of my most used libraries in the global environment.

### Install vim's administration manager
