Set-Location $HOME
if (!(Test-Path $HOME/dotfiles)) {
  git clone https://github.com/SARDONYX-sard/dotfiles $HOME/dotfiles
}

# --------------------------------------------------------------------------------------------------
# Require:
# --------------------------------------------------------------------------------------------------
# Install software with scoop
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/scoop.ps1"

# Git settings
Invoke-Expression "$HOME/dotfiles/windows/setup/git-setting.ps1"

#! Module loading must be done before symlink, otherwise symlink settings will not be reflected.
# Install powershell modules
Invoke-Expression "$HOME/dotfiles/windows/bin/installers//pwsh-modules.ps1"

# Connect each file (or directory) to dotfiles with a symbolic link.
Invoke-Expression "$HOME/dotfiles/windows/setup/symlink.ps1"

winget import "$HOME/dotfiles/windows/data/winget-app-list.json"

# --------------------------------------------------------------------------------------------------
# Option: Install languages or Libraries
# --------------------------------------------------------------------------------------------------
Write-Host "Option: You can include the global package of programming languages or Libraries." -ForegroundColor Blue
Write-Host @'
How to install with Scoop:
  Execute the following commands.↓

  Example:
    Node.js only
      windows\bin\installers\nodejs.ps1 -Manager pnpm

    All languages(Node.js, Ruby, python and msys2 libs)
      windows\bin\installers\all-languages.ps1
'@

# -- install dein.vim
git clone https://github.com/Shougo/dein.vim $HOME/.cache/dein/repos/github.com/Shougo/dein.vim
