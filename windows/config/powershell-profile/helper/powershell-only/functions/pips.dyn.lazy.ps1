if ((Get-Command pip -ErrorAction SilentlyContinue) -and (Get-Command pip_search -ErrorAction SilentlyContinue)) {
  pip_search $args
}
