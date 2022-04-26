function Get-Env { Get-ChildItem Env:* }

function Set-Env {
  [CmdletBinding()]
  param (
    [string] $Key = "path",
    [Parameter(Mandatory = $true,
      ValueFromPipeline = $true)]
    [string] $Value
  )
  [System.Environment]::SetEnvironmentVariable($Key, "$Value" + [System.Environment]::GetEnvironmentVariable('path', "User"), "User")

  if ($?) { Write-Host "Set-Env: $Key += $Value" }
  else { Write-Host "Set-Env: $Key += $Value failed" }
}

function Get-Path {
  $toReplaceStr = ";`n"
  [regex]::Replace($ENV:PATH, ";", "$toReplaceStr") | Sort-Object | Write-Host
}
