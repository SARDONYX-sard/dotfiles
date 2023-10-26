# Lazy loading(https://gist.github.com/hyrious/65c85889e18e916fe0a170f919afb5c1)
$local:LazyLoadProfile = [PowerShell]::Create()
[void]$LazyLoadProfile.AddScript(@"
  Import-Module posh-git
  @("behaviors", "external-modules-settings") | ForEach-Object {
    $local:ImportFullDirectory = "$HelperDir\$_";
    if (Test-Path $ImportFullDirectory) {
      Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include "*.ps1" |
      ForEach-Object {
        . $_.FullName
      }
    }
  }
"@)
$LazyLoadProfileRunspace = [RunspaceFactory]::CreateRunspace()
$LazyLoadProfile.Runspace = $LazyLoadProfileRunspace
$LazyLoadProfileRunspace.Open()
[void]$LazyLoadProfile.BeginInvoke()

$null = Register-ObjectEvent -InputObject $LazyLoadProfile -EventName InvocationStateChanged -Action {
  if ($PSVersionTable.PSEdition -eq 'Core') {
    oh-my-posh --init --shell pwsh --config "$HOME\dotfiles\common\data\oh-my-posh-themes\my-custom.json" | Invoke-Expression
    Import-Module posh-git
    # https://docs.microsoft.com/powershell/module/psreadline/about/about_psreadline?view=powershell-7.2
  }

  @('behaviors', 'external-modules-settings') | ForEach-Object {
    $local:ImportFullDirectory = "$HelperDir\$_";
    if (Test-Path $ImportFullDirectory) {
      Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Include '*.ps1' |
      ForEach-Object {
        . $_.FullName
      }
    }
  }

  if ($PSVersionTable.PSEdition -eq "Core") {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    # For VSCode terminl
    if ($Host.UI.RawUI.WindowSize.Height -ge 15) {
      Set-PSReadLineOption -PredictionViewStyle ListView
    }
  }
  $LazyLoadProfile.Dispose()
  $LazyLoadProfileRunspace.Close()
  $LazyLoadProfileRunspace.Dispose()
}
