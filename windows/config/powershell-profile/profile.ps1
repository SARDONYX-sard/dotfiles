# Measure-Script {

$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";

#! These files could not be lazily loaded.
. "$($HelperDir)/index.ps1"
. "$($HelperDir)/shell-behavior.ps1"


function prompt {
  <#
  This function is lazy load. Put off heavy processing to speed up startup.
  If lazy loading is possible, put it in the this function as much as possible.
  #>
  . "$($HelperDir)/shell-design.ps1"
  . "$($HelperDir)/shell-behavior-core.ps1"
  . "$($HelperDir)/index.lazy.ps1"
}

# }
