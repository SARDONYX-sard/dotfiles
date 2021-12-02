

Set-Location $HOME
git clone https://github.com/SARDONYX-sard/dotfiles $HOME/dotfiles

~/dotfiles/windows/setup/scoop-install.ps1
~/dotfiles/windows/setup/git-setting.ps1

#? $HOME env not working. So use `~`
~/dotfiles/windows/setup/symlink.ps1

winget import "$HOME/dotfiles/windows/data/winget-app-list.json"

# -- install dein.vim
git clone https://github.com/Shougo/dein.vim $HOME/.cache/dein/repos/github.com/Shougo/dein.vim
