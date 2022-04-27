if ($PSVersionTable.PSEdition -eq "Core") {
  Import-Module posh-git
  Set-PSReadLineOption -PredictionSource History #* Core only module

  if (Get-Command vcpkg) { Import-Module "$HOME\vcpkg\scripts\posh-vcpkg" }

  $ImportBaseDirectory = "$HOME\dotfiles\windows\config\powershell-profile\helper";
  @("lazy-load-modules") | ForEach-Object {
    $ImportFullDirectory = "$ImportBaseDirectory\$_";

    if (Test-Path $ImportFullDirectory) {
      Get-ChildItem -Path $ImportFullDirectory -File -Recurse -Exclude "*.md" |
      ForEach-Object { . $_.FullName }
    }
  }

}
