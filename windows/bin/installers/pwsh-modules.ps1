# --------------------------------------------------------------------------------------------------
# Modules
# --------------------------------------------------------------------------------------------------
# Modules that run only on PowerShell Core
if ($PSVersionTable.PSEdition -eq "Core") {
  $CoreOnlyLibs = @(
    'PowerType' # Auto complete
    'WslInterop' # use WSL commands on pwsh(nothing `wsl` prefix)
  )
  Install-Module -Name $CoreOnlyLibs -Scope CurrentUser -Force
}

$libs = @(
  'PSProfiler', # Measure reading time of $PFOFILE (https://github.com/IISResetMe/PSProfiler)
  'PSReadLine'  # Autosuggestions
)
foreach ($lib in $libs) {
  if (!(Get-Module -ListAvailable $lib -ErrorAction SilentlyContinue)) {
    Install-Module -Name $lib -Scope CurrentUser -Force
  }
}
