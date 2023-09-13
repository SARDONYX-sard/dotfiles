function Set-Complition {
  param (
    [Parameter(Mandatory = $true, HelpMessage = "Complition command name.")]
    [ValidateNotNullOrEmpty()]
    [string]$CmdName,

    [ValidateNotNullOrEmpty()]
    [Parameter(Mandatory = $true, HelpMessage = "Create complition command.")]
    [string]$CreateCmpCmd
  )

  $cmp_dir = "$HOME/.cache/pwsh/completion"
  $cmp_file = "$cmp_dir/$CmdName.ps1"

  if (Get-Command $CmdName -ErrorAction SilentlyContinue) {
    if (!(Test-Path $cmp_file)) {
      New-Item $cmp_dir -ItemType Directory -ErrorAction SilentlyContinu
      $CreateCmpCmd | Invoke-Expression > $cmp_file
    }
    . $cmp_file
  }
}
Enable-PowerType -LazyLoad
Set-Complition -CmdName rye -CreateCmpCmd "rye self completion --shell powershell"
Set-Complition -CmdName rustup -CreateCmpCmd "rustup completions powershell | Out-String"
Set-Complition -CmdName deno -CreateCmpCmd "deno completions powershell"

# windows\bin\installers\pwsh-modules.ps1
Import-Module -Name CompletionPredictor
Import-Module npm-completion
