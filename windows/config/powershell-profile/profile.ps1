#! use `CRLF` for powershell compatibility
# Measure-Script {j

$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";

. "$($HelperDir)/aliases.ps1"
. "$($HelperDir)/completion.ps1"
. "$($HelperDir)/functions.ps1"
. "$($HelperDir)/module-settings.ps1"

function prompt {
  . "$($HelperDir)/shell-design.ps1"

  # Bell OlFF
  if ((Get-PSReadlineOption).BellStyle -eq "Audible") { Set-PSReadlineOption -BellStyle None }
}

# msys2
#! This statement must be at the end of the profile or the command will be lost for some reason.
#! Without this, msys2 will not inherit windows environment variables.
if (Get-Command msys2 -ea 0) { $env:MSYS2_PATH_TYPE = "inherit" }
# }
