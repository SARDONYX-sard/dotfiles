if (Get-Command sudo -ErrorAction SilentlyContinue) {
  sudo winget upgrade --all
}
