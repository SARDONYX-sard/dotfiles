# --------------------------------------------------------------------------------------------------
# Modules
# --------------------------------------------------------------------------------------------------
# Modules that run only on PowerShell Core
if ($PSVersionTable.PSEdition -eq "Core") {
  $CoreOnlyLibs = @()
  Install-Module -Name $CoreOnlyLibs -Scope CurrentUser -Force
}

$libs = @(
  'PSFzf', # To use fzf on windows(`fzf` is installed by scoop)
  'PSProfiler', # Measure reading time of $PFOFILE (https://github.com/IISResetMe/PSProfiler)
  'PSReadLine', # Autosuggestions
  'WslInterop' # use WSL commands on pwsh(nothing `wsl` prefix)
)
foreach ($lib in $libs) {
  if (!(Get-Module -ListAvailable $lib -ErrorAction SilentlyContinue)) {
    Install-Module -Name $lib -Scope CurrentUser -Force
  }
}
