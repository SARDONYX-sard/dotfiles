Set-Location $HOME
if (!(Test-Path $HOME/dotfiles)) {
  git clone https://github.com/SARDONYX-sard/dotfiles $HOME/dotfiles
}

Invoke-Expression "$HOME/dotfiles/windows/setup/scoop-install.ps1"
Invoke-Expression "$HOME/dotfiles/windows/setup/git-setting.ps1"

#? $HOME env not working. So use `~`
~/dotfiles/windows/setup/symlink.ps1

winget import "$HOME/dotfiles/windows/data/winget-app-list.json"

# Install powershell modules
Invoke-Expression "$HOME/dotfiles/windows/setup/pwsh-modules.ps1"

# -- install dein.vim
git clone https://github.com/Shougo/dein.vim $HOME/.cache/dein/repos/github.com/Shougo/dein.vim
