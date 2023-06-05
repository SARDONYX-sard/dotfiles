if (Get-Command pip_search -ErrorAction SilentlyContinue) {
  if ($args[0] -eq "search") {
    pip_search @($args | Select-Object -Skip 1)
  }
  else {
    pip.exe @args
  }
}
else {
  pip.exe @args
}
