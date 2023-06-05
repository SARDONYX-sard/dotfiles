if (Get-Command scoop-search -ErrorAction SilentlyContinue) {
  if ($args[0] -eq "search") {
    scoop-search.exe @($args | Select-Object -Skip 1)
  }
  else {
    scoop.ps1 @args
  }
}
else {
  scoop.ps1 @args
}
