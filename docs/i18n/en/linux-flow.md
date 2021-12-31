# Linux Flow

- [Linux Flow](#linux-flow)
  - [Getting Started](#getting-started)
  - [In PowerShell](#in-powershell)
  - [install-wsl.sh](#install-wslsh)
  - [linux/symlink.sh](#linuxsymlinksh)
  - [output .gitconfig to $HOME](#output-gitconfig-to-home)
  - [linux/bin/all-installer.sh](#linuxbinall-installersh)

## Getting Started

If you want to set up a WSL environment with dotfiles, it is recommended to run
`install-win.ps1` first. The three reasons are as follows.

- It automatically installs WSL for you.
- You have to prepare prerequisite commands such as git manually.
- scoop is registered as an environment variable (you can use it to get the
  windows username from WSL and connect a symbolic link to the windows
  dotfiles).

However, if you already have these, it should be easy to run.

## In PowerShell

- For WSL, you need to `git clone` the dotfiles to $HOME on Windows.
- If you ran `install-win.ps1` earlier, you don't need to do this because this
  operation is already finished automatically.

```powershell
git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME/dotfiles
```

## install-wsl.sh

- Unlike windows, this is the core file for setup this time.
- Passing the zsh string as argument will switch to zsh.
  `sudo bash install-wsl.sh zsh`.

- Run the following command in a WSL or Linux terminal

```bash
sudo bash install-wsl.sh
```

- In this file, it automatically detects whether WSL, Linux itself, or Msys2 is
  used, and dynamically determines the folder to connect the symbolic link.

The determined value is stored in the `HOME_DIR` variable.

For Linux: $HOME_DIR = /home/linux username/

For WSL: $HOME_DIR = /mnt/c/Users/**windows username**/

For Msys2: $HOME_DIR = /c/Users/**windows username**/

## linux/symlink.sh

- In the case of WSL, use the Windows $HOME directory determined from the
  environment variable of scoop to connect the symbolic link.

## output .gitconfig to $HOME

## linux/bin/all-installer.sh

Install the administration manager with bash, and install useful packages with
the nuclear administration manager.

There are several package installers in linux/bin/installer, but you can install
them as you like.

If there are packages you do not want to install, click
[here](../../../linux/bin/all-installer.sh) and comment it out.

Examples of packages:

- Useful packages with apt
- Installing a programming language with asdf
- Install oh-my-posh by homebrew (to change the design of the terminal)
- Install rustup (to use cargo for faster commands such as `procs`, and to use
  rust) It is possible to use asdf to manage the system, but I decided that it
  is not necessary, because the convenience of rustup is much better.
