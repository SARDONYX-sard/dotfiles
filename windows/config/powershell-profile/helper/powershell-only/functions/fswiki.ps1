if (Get-Command fswiki -ErrorAction SilentlyContinue) {
  function wk { fzwiki $args  -l ja }
}
