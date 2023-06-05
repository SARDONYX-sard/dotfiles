if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression "z $args;ls"
}
else {
  Set-Location @args
}
