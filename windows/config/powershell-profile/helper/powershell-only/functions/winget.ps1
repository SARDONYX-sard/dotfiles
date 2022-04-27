if (Get-Command winget -ErrorAction SilentlyContinue) {
  function wg ($cmd) {
    switch -Regex ($cmd) {
      "^(?:i|install)$" { winget install $args }
      "^(?:uni|uninstall)$" { winget uninstall $args }
      "^(?:s|search)$" { winget search $args }
      "^(?:ls|list)$" {
        if ($Args[0] -ne "") {
          winget list $Args[0]
        }
        else {
          winget list
        }
      }
      "^(?:up|upgrade)$" { winget upgrade $args }

      Default { winget $cmd }
    }
  }

  if (Get-Command sudo) {
    function wua { sudo winget upgrade --all }
  }
}
