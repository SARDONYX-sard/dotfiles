<#
.Notes
  Enhanced Invoke-Item command
  which open directory environment path
#>

# Remove-Item alias:ii -Force # already used by Invoke-Item

# Invoke-Item Open
function iio {
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

  if ($PSVersionTable.PSEdition -eq "Core") {
    explorer.exe /e, /select, $path
  }
  elseif ($PSVersionTable.PSEdition -eq "Desktop") {
    explorer.exe $path
  }
}

# Invoke-Item Open All
function iia($cmd) {
  which $cmd -a | ForEach-Object {
    if ($_.CommandType -ne "Function") {
      explorer.exe /e, /select, $_.Source
    }
  }
}
