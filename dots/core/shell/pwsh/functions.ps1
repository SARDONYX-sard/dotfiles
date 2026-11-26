# PowerShell-only helpers (pwsh 7 and 5.1). Loaded on first idle by profile.ps1,
# hence `global:`. Keep 5.1-compatible syntax.

# Open an elevated shell of the same kind (pwsh or powershell).
function global:su { Start-Process (Get-Process -Id $PID).Path -Verb RunAs }

# Enter the Visual Studio developer shell (cl, clang, vcpkg in PATH).
function global:vsdev {
  $vs = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -property installationPath
  Import-Module (Join-Path $vs 'Common7\Tools\Microsoft.VisualStudio.DevShell.dll')
  Enter-VsDevShell -VsInstallPath $vs -SkipAutomaticLocation -Arch amd64 -HostArch amd64
}

# Prepend a value to a *user* environment variable (persistent).
function global:Add-UserEnv {
  param([Parameter(Mandatory)][string]$Value, [string]$Key = 'PATH')
  $old = [Environment]::GetEnvironmentVariable($Key, 'User')
  $new = if ($old) { "$Value;$old" } else { $Value }
  [Environment]::SetEnvironmentVariable($Key, $new, 'User')
  Write-Host "$Key = $new"
}

# `scoop search` via the much faster scoop-search when installed.
function global:scoop {
  if ($args[0] -eq 'search' -and (Get-Command scoop-search -ErrorAction Ignore)) {
    scoop-search @($args | Select-Object -Skip 1)
  } else { scoop.ps1 @args }
}
