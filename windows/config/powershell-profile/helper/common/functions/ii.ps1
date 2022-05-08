# Enhanced Invoke-Item command
# which open directory environment path

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

  $path = Convert-Path $(which $cmd)
  if ($Null -eq $path) {
    Invoke-Item $cmd
    return;
  }

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
