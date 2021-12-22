#! use `CRLF` for powershell compatibility
# Measure-Script {

$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";

#! These files could not be lazily loaded.
. "$($HelperDir)/aliases.ps1"
. "$($HelperDir)/completion.ps1"
. "$($HelperDir)/functions.ps1"
. "$($HelperDir)/module-settings.ps1"


# This function is lazy load. Put off heavy processing to speed up startup.
# If lazy loading is possible, put it in the this function as much as possible.
function prompt {
  Set-PSReadlineOption -BellStyle None

  # Increase load time if shell-design is not loaded first.
  . "$($HelperDir)/shell-design.ps1"
  . "$($HelperDir)/lazy-load-module.ps1"

}

# msys2
#! This statement must be at the end of the profile or the command will be lost for some reason.
#! Without this, msys2 will not inherit windows environment variables.
if (Get-Command msys2 -ea 0) { $env:MSYS2_PATH_TYPE = "inherit" }
# }
