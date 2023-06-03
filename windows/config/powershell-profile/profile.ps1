[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
$executionTime = $(Measure-Command {
    $HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";
    . "$($HelperDir)/index.ps1" #! These files could not be lazily loaded.
    function prompt {
      # This function is lazy load. Put off heavy processing to speed up startup.
      . "$($HelperDir)/shell-design.ps1"
      . "$($HelperDir)/index.lazy.ps1"
    }
    . "$($HelperDir)/enhanced-lazy.ps1" # Enable lazy loading for some modules where lazy loading does not work in the prompt function.
  }).TotalMilliseconds
