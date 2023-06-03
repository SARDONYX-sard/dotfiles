@("common", "linux-compatible", "powershell-only") | ForEach-Object {
  $local:ImportFullDirectory = "$HelperDir\$_";
  if (Test-Path $ImportFullDirectory) {
    Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.ps1" -Exclude "*.lazy.ps1" |
    ForEach-Object {
      . $_.FullName
    }
  }
}
