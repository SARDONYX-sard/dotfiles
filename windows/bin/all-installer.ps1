Invoke-Expression "$HOME/dotfiles/windows/bin/installers/cargo.ps1"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/flutter.ps1"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/keyhac.ps1"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/msys2.ps1"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/nodejs.ps1 -Manager pnpm"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/pwsh-modules.ps1"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/pyenv-win.ps1"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/python.ps1 -Manager pip"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/ruby.ps1"
Invoke-Expression "$HOME/dotfiles/windows/bin/installers/scoop.ps1"


if (Test-Path dotnet-core-uninstall) {
  Write-Host "Manual install dotnet-core-uninstall(to remove Microsoft SDK)"
  Write-Host "https://github.com/dotnet/cli-lab/releases"
  Write-Host ""
  Write-Host "How to use: https://qiita.com/okazuki/items/b1a04dc58064c37372e0"
}
