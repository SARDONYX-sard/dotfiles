param(
  $cmd
)

if (Get-Command winget -ErrorAction SilentlyContinue) {
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
