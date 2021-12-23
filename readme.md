# dotfiles

English | [日本語](./docs/i18n/jp/readme.md)

<p style="display:flex;justify-content:space-around;">
    <img src="./docs/images/powershell-core.png" alt="powershell-core" height="300" width="400"/>
    <img src="./docs/images/wsl-ubuntu.png" alt="wsl-ubuntu"  height="300" width="400"/>
</p>

- It does not come with a background image for the prompt.
- We have confirmed that the files work by themselves, but we have not tested
  the integration, so we cannot guarantee that they work.

## Table of Contents

- [dotfiles](#dotfiles)
  - [Table of Contents](#table-of-contents)
  - [Author's operating environment](#authors-operating-environment)
  - [How to install](#how-to-install)
    - [windows](#windows)
    - [GNU/Linux](#gnulinux)
  - [Progress](#progress)
  - [Note '!'](#note-)
  - [Things you have to do manually](#things-you-have-to-do-manually)
    - [Windows-Terminal](#windows-terminal)
    - [.gitconfig](#gitconfig)
  - [How it works](#how-it-works)
  - [Reference site](#reference-site)
  - [License](#license)

## Author's operating environment

- Windows11 Home
- WSL(Ubuntu)

## How to install

### windows

Execute the following command.

```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/install-win.ps1')
```

### GNU/Linux

This is possible on WSL or Linux. The execution behavior for each is as follows.

Linux (not WSL): The dotfiles will be placed in $HOME in linux, and symbolic
links will be placed around it.

WSL: The dotfiles are placed on the Windows side, and the symbolic link is
connected to WSL from there.

- Linux (not WSL)

Execute the following command.

```bash
# Can be done on Windows or linux
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME/dotfiles

cd ~/dotfiles
sudo bash "install-wsl.sh"
```

- WSL(Windows Subsystem for Linux)

1.Execute the following command in PowerShell.(Not required if you have already run the [Windows dotfiles](###Windows) configuration.)

```powershell
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME/dotfiles
```

2.Execute the following command in WSL.

USERNAME problem reference:
[reddit](https://www.reddit.com/r/bashonubuntuonwindows/comments/8dhhrr/is_it_possible_to_get_the_windows_username_from/)

```bash
export USERNAME=`cmd.exe /c echo %username%`
cd /mnt/c/Users/${USERNAME}/dotfiles
sudo bash ". /install-wsl.sh"
```

## Progress

- Completed

  - Windows settings
  - Linux settings

- Incomplete

  - Minor bug fixes
  - Unchecked reproducibility (especially WSL)
  - Add test code

## Note '!'

- This is the setup repository for my development environment. If you do not
  know what you are doing, do not run this code unnecessarily. If you run it
  easily, your current development environment will be overwritten by my
  development environment settings.

- Some settings are in Japanese and may not be suitable for English speakers.

- This project is based on the dotfiles project from
  [here](https://github.com/LumaKernel/dotfiles). A huge thanks to him...

## Things you have to do manually

- Rewrite the user name with `Hard coded` and comments. (Please use the search
  function of the editor).

- (Use the search function of the editor.) However, since the path of `scoop` is
  currently used to find the user name of `windows`, if the path of `scoop` can
  be recognized by WSL, there is almost no need to rewrite it.

### Windows-Terminal

- The windows-terminal configuration file is automatically generated and is not
  suitable for your environment. You will need to adapt the user name and other
  settings to your PC.

### .gitconfig

- At least you have to rewrite the Git config username and email address. You
  can register by running the following command in a terminal.

```bash
git config --global user.name "Your name"
git config --global user.email "Your email address"
```

## How it works

See below.

[windows flow](./docs/i18n/en/windows-flow.md)

[linux-flow](./docs/i18n/en/linux-flow.md)

## Reference site

- <https://github.com/LumaKernel/dotfiles>

- [Everything you wanted to know about hashtables](https://docs.microsoft.com/en/powershell/scripting/learn/deep-dives/everything-about-hashtable?view=powershell-7.2)

- [Optimizing your $Profile](https://devblogs.microsoft.com/powershell/optimizing-your-profile/)

## License

Unlicense
