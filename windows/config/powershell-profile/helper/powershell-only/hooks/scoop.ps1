if (Get-Command scoop-search -ErrorAction SilentlyContinue) {
  # Makes scoop search 50 times faster. (Couldn't lazy load.)
  Invoke-Expression (&scoop-search --hook)
}
