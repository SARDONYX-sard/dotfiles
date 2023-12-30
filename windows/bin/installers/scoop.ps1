<#
.SYNOPSIS
  Batch to install apps on scoop

.DESCRIPTION
  Batch to install apps on scoop
.EXAMPLE
  windows\setup\scoop-install.ps1
.EXAMPLE
  # Install Languages too.
  windows\setup\scoop-install.ps1 -Light
#>
Param (
  [switch]$Light
)

# settings
# WARN  Scoop uses 'aria2c' for multi-connection downloads.
# WARN  Should it cause issues, run 'scoop config aria2-enabled false' to disable it.
scoop config aria2-warning-enabled false

# --------------------------------------------------------------------------------------------------
# Aliases(to like pnpm commands) reference: JP(https://qiita.com/nimzo6689/items/53c63439f56ccd2d38c1)
# --------------------------------------------------------------------------------------------------
# install
scoop alias add i 'scoop install $args[0]' 'Install Scoop apps.'
scoop alias add add 'scoop install $args[0]' 'Install Scoop apps.'

# uninstall
scoop alias add uni 'scoop uninstall $args[0]' 'Remove Scoop apps.'
scoop alias add rm 'scoop uninstall $args[0]' 'Remove Scoop apps.'
scoop alias add remove 'scoop uninstall $args[0]' 'Remove Scoop apps.'

# upgrade
scoop alias add upgrade 'scoop update *' 'Update all apps.'
scoop alias add up 'scoop upgrade' 'Update all apps.'

# Delete cache
scoop alias add prune 'scoop cleanup * --cache' 'Clean Scoop apps by removing old versions and caches.'

# Update all & show status
scoop alias add outdated 'scoop update; scoop status' 'Show all outdated Scoop apps.'

# reinstall
scoop alias add ri 'scoop uninstall $args[0]; scoop install $args[0]' 'Uninstall and then install app'
scoop alias add reinstall 'scoop uninstall $args[0]; scoop install $args[0]' 'Uninstall and then install app'

scoop alias add ls 'scoop list' 'Show installed apps list'

scoop alias add s 'scoop search $args[0]' 'Search Scoop apps'

# reset(To nvm like)
scoop alias add rs 'scoop reset $args[0]' 'Reset an app to resolve conflicts'
scoop alias add use 'scoop reset $args[0]' 'Reset an app to resolve conflicts'


Write-Host "Next, install app by scoop..." -ForegroundColor Green
# --------------------------------------------------------------------------------------------------
# Add fetch destination
# --------------------------------------------------------------------------------------------------
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts # For Terminal(oh-my-posh design) font(https://github.com/matthewjberger/scoop-nerd-fonts)
# scoop bucket add games # Option Citra(3DS Emu) etc.

scoop bucket add jp https://github.com/dooteeen/scoop-for-jp # To use a special gvim with background transparency applied.
scoop bucket add myBuket https://github.com/amano41/scoop-bucket.git # For keyhac


# --------------------------------------------------------------------------------------------------
# Unix like for Windows
# --------------------------------------------------------------------------------------------------
scoop install mobaxterm # Enhanced terminal for Windows with X11 server.(https://mobaxterm.mobatek.net)
scoop install direnv    # Load or unload environment variables depending on the current directory
scoop install OpenSSH   # SSH client for Windows

scoop install make
# scoop install psutils # The sudo command is included. This is global issunstooled in `install-win.ps1`.

# DB
scoop install sqlite  # Lightweight Database

# Better Linux command(Runs faster than existing ones.)
scoop install bat     # instead of `cat` Syntax highlighting and Git integration(https://github.com/sharkdp/bat)
scoop install dog     # instead of `dig` commnad
scoop install duf     # It's volume size analyzer.
scoop install fd      # instead of `find` commnad with color
scoop install less    # latest less command
scoop install lsd     # instead of `ls` commnad with color
scoop install procs   # instead of `ps` commnad with color
scoop install ripgrep # instead of `grep` commnad with color
scoop install sd      # instead of `sed` commnad
scoop install xh      # Http reqests like curl
scoop install zoxide  # instead of cd(Allows ambiguous travel to dirs that have been there.)
scoop install tre-command # improved Rust `tree` command.

# --------------------------------------------------------------------------------------------------
# Shell design
# --------------------------------------------------------------------------------------------------
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
scoop install CodeNewRoman-NF-Mono


# --------------------------------------------------------------------------------------------------
# Code Conventions
# --------------------------------------------------------------------------------------------------
# Formatter
scoop install shfmt # Makefile formatter

# Linter
scoop install hadolint # Docker linter
scoop install shellcheck # Shell linter


# --------------------------------------------------------------------------------------------------
# Convenience
# --------------------------------------------------------------------------------------------------
# Helper
scoop install hugo            # Static site generator
scoop install luacheck        # lua package manager(to use neovim lua ckeck)
scoop install git-filter-repo # The subcommand `git filter-repo` can be used to modify the git history.

scoop install keyhac          # keyboard key editor
#? To enable the `$env:AppData\keyhac` path setting
Remove-Item $HOME\scoop\apps\keyhac\current\keyhac.ini
Remove-Item $HOME\scoop\apps\keyhac\current\config.py
Remove-Item $HOME\scoop\apps\keyhac\current\_config.py

# Terminal helper
scoop install bottom           # Resource monitor with CLI (https://github.com/ClementTsang/bottom)
scoop install broot            # A better way to navigate directories
# scoop install concfg           # Import and export Windows console settings (https://github.com/lukesampson/concfg)
scoop install fzf              # A command-line fuzzy finder written in go.(https://github.com/junegunn/fzf)
scoop install gh               # GitHub Action in local PC.(https://cli.github.com/manual/)
scoop install k9s              # Kubernetes wrapper
scoop install lazydocker       # Better useful Docker wrapper
# scoop install lazygit          # Better useful Git wrapper
scoop install gitui            # GitUI provides you with the comfort of a git GUI but right in your terminal
scoop install scoop-search     # Makes scoop search 50 times faster.(https://github.com/shilangyu/scoop-search)
scoop install tokei            # A terminal code analyzer.

# --------------------------------------------------------------------------------------------------
# Completion
# --------------------------------------------------------------------------------------------------
scoop install dockercompletion
scoop install scoop-completion
scoop install npm-completion


# --------------------------------------------------------------------------------------------------
# File converter
# --------------------------------------------------------------------------------------------------
# Image converter
# I use realesrgan-ncnn-vulkan now.see more: https://github.com/xinntao/Real-ESRGAN/releases

# scoop install imagemagick
scoop install pandoc      # Markdown to PDF


# --------------------------------------------------------------------------------------------------
# Editor
# --------------------------------------------------------------------------------------------------
scoop install neovim
scoop install vim-kaoriya # Transparently applied version of gvim.exe

# Editor helper
scoop install ctags # For jump to reference


# --------------------------------------------------------------------------------------------------
# Binaly Analysis
# --------------------------------------------------------------------------------------------------
scoop install radare2 # use r2 command
# scoop install ollydbg # binary analyzer GUI
sudo scoop install ida-free # Need Administrator. GUI

# --------------------------------------------------------------------------------------------------
# PowerShell Modules
# --------------------------------------------------------------------------------------------------
scoop install posh-git         # Git tab completion (https://github.com/dahlbyk/posh-git)
scoop install psfzf            # To use fzf on windows(`fzf` is installed by scoop)


# --------------------------------------------------------------------------------------------------
# Performance Scanner
# --------------------------------------------------------------------------------------------------
scoop install hyperfine # A benchmarking tool written in rust.(https://github.com/sharkdp/hyperfine)


# --------------------------------------------------------------------------------------------------
# Languages(option)
# --------------------------------------------------------------------------------------------------
if (! $Light) {
  scoop install perl     # For wasm-pack(cargo Rust WebAssembly)
  scoop install deno
  scoop install llvm     # Foundation for creating programming languages.(clang.exe)
}
