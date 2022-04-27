param (
  [switch]$Light
)

$installer = "$HOME/dotfiles/windows/bin/installers"

if ($Light) {
  Invoke-Expression "$installer/scoop.ps1 -Light"
}
else {
  Invoke-Expression "$installer/scoop.ps1"
}

Invoke-Expression "$installer/pwsh-modules.ps1"

if (! $Light) {
  Invoke-Expression "$installer/cargo.ps1"
  Invoke-Expression "$installer/flutter.ps1"
  Invoke-Expression "$installer/msys2.ps1"
  Invoke-Expression "$installer/nodejs.ps1 -Manager pnpm"
  Invoke-Expression "$installer/pyenv-win.ps1"
  Invoke-Expression "$installer/pip.ps1 -m pip --plus"
  Invoke-Expression "$installer/ruby.ps1"
}


if (Test-Path dotnet-core-uninstall) {
  Write-Host "Manual install dotnet-core-uninstall(to remove Microsoft SDK)"
  Write-Host "https://github.com/dotnet/cli-lab/releases"
  Write-Host ""
  Write-Host "How to use: https://qiita.com/okazuki/items/b1a04dc58064c37372e0"
}

Write-Host @"
Option: LunarVim installation

Invoke-Expression "$HOME\dotfiles\windows\bin\installers\lvim.ps1"
"@
