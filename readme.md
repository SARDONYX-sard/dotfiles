# dotfiles

[日本語](./docs/i18n/jp/readme.md)

- This project is currently under development. If you run it carelessly, you may
  get errors.

## Table of Contents

- [dotfiles](#dotfiles)
  - [Table of Contents](#table-of-contents)
  - [How to install](#how-to-install)
    - [windows](#windows)
    - [GNU/Linux](#gnulinux)
  - [Progress](#progress)
  - [Warning'!'](#warning)
  - [Things you have to do manually](#things-you-have-to-do-manually)
  - [Workarounds I've done for coding](#workarounds-ive-done-for-coding)
  - [Reference sites](#reference-sites)
  - [License](#license)

## How to install

Execute the following command.

### windows

以下のコマンドを実行します。

```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/install-win.ps1')
```

### GNU/Linux

- Linux (not WSL)

Execute the following command.

```bash
# Can be done on Windows or linux
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME

cd ~/dotfiles
bash "install-wsl.sh"
```

- WSL(Windows Subsystem for Linux)

1.Execute the following command in PowerShell.

```powershell
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME
```

2.Execute the following command in WSL.

```bash
# reference: (https://www.reddit.com/r/bashonubuntuonwindows/comments/8dhhrr/is_it_possible_to_get_the_windows_username_from/)

export USERNAME=`cmd.exe /c echo %username%`
cd /mnt/c/Users/${USERNAME}/dotfiles
install-wsl.sh
```

## Progress

- Completed

  - Windows settings
  - Linux settings

- Incomplete

  - Minor bug fixes
  - Unchecked reproducibility (especially WSL)
  - Add test code

## Warning'!'

- This is the setup repository for my development environment. If you do not
  know what you are doing, do not run this code unnecessarily. If you run it
  easily, your current development environment will be overwritten by my
  development environment settings.

- Some settings are in Japanese and may not be suitable for English speakers.

- This project is based on the dotfiles project from
  [here](https://github.com/LumaKernel/dotfiles). A huge thanks to him...

## Things you have to do manually

- Rewrite the user name with `hard coded` and comments. (Please use the search
  function of the editor).

## Workarounds I've done for coding

Some of them are left in the comments, but I'll include them here as well.

- In `git clone`, `~` is not expanded and becomes a directory called `~`. For
  this reason, we use the `$HOME` variable.
- Running the `ps1` file did not expand `$HOME`, so the `~` variable is used.

## Reference sites

- <https://github.com/LumaKernel/dotfiles>

## License

Unlicense
