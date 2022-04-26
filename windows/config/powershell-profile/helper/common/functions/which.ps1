# which open directory environment path
function w ($cmd) {

  $path = Convert-Path $(which $cmd)
  Write-Host "Open with explorer " -ForegroundColor Green -NoNewline
  Write-Host "`"$path`"" -ForegroundColor Yellow
  explorer.exe /e, /select, $path
}
