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
