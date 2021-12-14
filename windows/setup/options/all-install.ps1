windows\setup\options\libs\msys2.ps1
windows\setup\options\libs\nodejs.ps1 -Manager pnpm
windows\setup\options\libs\python.ps1 -Manager pip
windows\setup\options\libs\ruby.ps1

if (Test-Path dotnet-core-uninstall) {
  Write-Host "Manual install dotnet-core-uninstall(to remove Microsoft SDK)"
  Write-Host "https://github.com/dotnet/cli-lab/releases"
  Write-Host ""
  Write-Host "How to use: https://qiita.com/okazuki/items/b1a04dc58064c37372e0"
}
