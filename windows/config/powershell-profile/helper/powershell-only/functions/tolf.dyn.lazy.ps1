param(
  [string]$extension
)

if ($extension) {
  return Get-ChildItem -Recurse -File -Filter *.$extension |
  ForEach-Object { (([System.IO.File]::ReadAllText($_.FullName)) -replace "`r`n", "`n") |
    Set-Content -Encoding UTF8 -NoNewline $_.FullName }
}

Get-ChildItem -Recurse -File |
ForEach-Object { (([System.IO.File]::ReadAllText($_.FullName)) -replace "`r`n", "`n") |
  Set-Content -Encoding UTF8 -NoNewline $_.FullName }
