# Measure-Script {

$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";

#! These files could not be lazily loaded.
. "$($HelperDir)/index.ps1"


function prompt {
  <#
  This function is lazy load. Put off heavy processing to speed up startup.
  If lazy loading is possible, put it in the this function as much as possible.
  #>
  Set-PSReadLineOption -BellStyle None

  . "$($HelperDir)/shell-design.ps1"
  . "$($HelperDir)/index.lazy.ps1"
}

if ($PSVersionTable.PSEdition -eq "Core") {
  #! v7.90.1: Putting oh-my-posh in a separate file did not work, so put it here
  oh-my-posh --init --shell pwsh --config "$HOME\dotfiles\common\data\oh-my-posh-themes\my-custom.json" | Invoke-Expression
}
