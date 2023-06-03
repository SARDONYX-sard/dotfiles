# Measure-Script {

$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";

#! These files could not be lazily loaded.
. "$($HelperDir)/index.ps1"

function prompt {
  <#
  This function is lazy load. Put off heavy processing to speed up startup.
  If lazy loading is possible, put it in the this function as much as possible.
  #>
  . "$($HelperDir)/shell-design.ps1"
  . "$($HelperDir)/index.lazy.ps1"
}

# Enable lazy loading for some modules where lazy loading does not work in the prompt function.
. "$($HelperDir)/enhanced-lazy.ps1"

# }
