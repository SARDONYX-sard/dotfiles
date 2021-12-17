# --------------------------------------------------------------------------------------------------
# Modules
# --------------------------------------------------------------------------------------------------
Install-Module -Name PSFzf -Force # PsFzf(to use fzf on windows)

# Modules that run only on PowerShell Core
if ($PSVersionTable.PSEdition -eq "Core") {
  Import-Module -Name oh-my-posh -Force
  Install-Module -Name WslInterop -Force
  Install-Module -Name WslInterop -Force
}
