windows\bin\installers\cargo.ps1
windows\bin\installers\flutter.ps1
windows\bin\installers\keyhac.ps1
windows\bin\installers\msys2.ps1
windows\bin\installers\nodejs.ps1 -Manager pnpm
windows\bin\installers\python.ps1 -Manager pip
windows\bin\installers\ruby.ps1

if (Test-Path dotnet-core-uninstall) {
  Write-Host "Manual install dotnet-core-uninstall(to remove Microsoft SDK)"
  Write-Host "https://github.com/dotnet/cli-lab/releases"
  Write-Host ""
  Write-Host "How to use: https://qiita.com/okazuki/items/b1a04dc58064c37372e0"
}
