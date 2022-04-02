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

scoop bucket  add myBuket https://github.com/amano41/scoop-bucket.git # For keyhac


# --------------------------------------------------------------------------------------------------
# Unix like for Windows
# --------------------------------------------------------------------------------------------------
if (! $Light) {
  scoop install msys2     # windows in Unix shell: info JP(https://qiita.com/Ted-HM/items/4f2feb9fdacb6c72083c)
  msys2 -mintty
}
scoop install mobaxterm # Enhanced terminal for Windows with X11 server.(https://mobaxterm.mobatek.net)
scoop install direnv    # Load or unload environment variables depending on the current directory
scoop install OpenSSH   # SSH client for Windows

scoop install make
scoop install cmake
scoop install psutils

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
scoop install zoxide  # instead of cd


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
scoop install capture2text    # Can read text from video.
scoop install hugo            # Static site generator
scoop install resource-hacker # exe icon edit

scoop install keyhac          # keyboard key editor
#? To enable the `$env:AppData\keyhac` path setting
Remove-Item $HOME\scoop\apps\keyhac\current\keyhac.ini
Remove-Item $HOME\scoop\apps\keyhac\current\config.py
Remove-Item $HOME\scoop\apps\keyhac\current\_config.py

# Terminal helper
scoop install bottom           # Resource monitor with CLI (https://github.com/ClementTsang/bottom)
scoop install broot            # A better way to navigate directories
scoop install concfg           # Import and export Windows console settings (https://github.com/lukesampson/concfg)
scoop install dockercompletion
scoop install fzf              # A command-line fuzzy finder written in go.(https://github.com/junegunn/fzf)
scoop install gh               # GitHub Action in local PC.(https://cli.github.com/manual/)
scoop install k9s              # Kubernetes wrapper
scoop install lazydocker       # Better useful Docker wrapper
scoop install lazygit          # Better useful Git wrapper
scoop install scoop-search     # Makes scoop search 50 times faster.(https://github.com/shilangyu/scoop-search)
scoop install tokei            # A terminal code analyzer.


# --------------------------------------------------------------------------------------------------
# File converter
# --------------------------------------------------------------------------------------------------
# Image converter
scoop install imagemagick
scoop install waifu2x-ncnn-vulkan

scoop install pandoc      # Markdown to PDF
scoop install screentogif


# --------------------------------------------------------------------------------------------------
# Editor
# --------------------------------------------------------------------------------------------------
scoop install neovim
scoop install notepadplusplus

# Editor helper
scoop install ctags # For jump to reference


# --------------------------------------------------------------------------------------------------
# PowerShell Modules
# --------------------------------------------------------------------------------------------------
scoop install posh-git         # Git tab completion (https://github.com/dahlbyk/posh-git)
scoop install psfzf            # To use fzf on windows(`fzf` is installed by scoop)


# --------------------------------------------------------------------------------------------------
# Performance Scanner
# --------------------------------------------------------------------------------------------------
# Performance
scoop install hyperfine # A benchmarking tool written in rust.(https://github.com/sharkdp/hyperfine)


# --------------------------------------------------------------------------------------------------
# Languages(option)
# --------------------------------------------------------------------------------------------------
if (! $Light) {
  scoop install perl     # For wasm-pack(cargo Rust WebAssembly)
  scoop install deno
  scoop install python27 # latest python version (e.g. python2.7) for other software.
  scoop install llvm     # Foundation for creating programming languages.(clang.exe)
}
