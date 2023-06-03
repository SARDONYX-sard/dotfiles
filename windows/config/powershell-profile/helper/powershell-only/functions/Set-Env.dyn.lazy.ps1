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
