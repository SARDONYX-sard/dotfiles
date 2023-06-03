<#
.Notes
  Enhanced Invoke-Item command
  which open directory environment path
#>

# Remove-Item alias:ii -Force # already used by Invoke-Item

# Invoke-Item Open(e.g. iio rg)
[CmdletBinding()]
param(
  [Parameter(ValueFromPipeline = $True)]
  $cmd
)

if ($Null -eq $cmd) {
  explorer.exe $HOME
  return;
}

$path = which $cmd
if ($Null -eq $path) {
  Invoke-Item $cmd
  return;
}

$path = Convert-Path $path
Write-Host "Open with explorer " -ForegroundColor Green -NoNewline
Write-Host "`"$path`"" -ForegroundColor Yellow

Start-Process -FilePath C:\Windows\explorer.exe -ArgumentList "/select, ""$path"""
