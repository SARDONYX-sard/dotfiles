function Get-Env { Get-ChildItem Env:* }

function Set-Env {
  [CmdletBinding()]
  param (
    [string] $Key = "path",
    [Parameter(Mandatory = $true,
      ValueFromPipeline = $true)]
    [string] $Value
  )

  $OldValue = [System.Environment]::GetEnvironmentVariable($Key, "User")
  if ($NULL -ne $OldValue ) {
    $Value += ";"
  }

  [System.Environment]::SetEnvironmentVariable($Key, "$Value" + $OldValue, "User")

  if ($?) {
    Write-Host "[Success] " -ForegroundColor Green -NoNewline
    Write-Host "{ $Key`: $Value }"
  }
  else { Write-Error " [Failed] { $Key`: $Value }" }

  Write-Host "    [Now] " -ForegroundColor Cyan -NoNewline
  Write-Host "{ $Key`: $([System.Environment]::GetEnvironmentVariable($Key, "User")) }"
}

function Remove-Env {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true,
      ValueFromPipeline = $true)]
    [string] $Key
  )

  if ($Key.ToLower() -eq "path") {
    Write-Error " [Failed] Cannot remove path. It's dangerous."
    return $false
  }

  $Answer = Read-Host "[Warning] Are you sure you want to remove $Key? (y/n) " -ForegroundColor Yellow
  if (condition $Answer -eq "y") {
    Set-Env $Key $NULL
  }
  else {
    Write-Host "[Cancelled] Didn't' Remove $Key act." -ForegroundColor Cyan
  }

}

function Get-Path {
  $toReplaceStr = "; `n"
  [regex]::Replace($ENV:PATH, ";", "$toReplaceStr") | Sort-Object | Write-Host
}
