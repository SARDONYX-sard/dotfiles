[CmdletBinding()]
param (
  [switch]$d,
  [switch]$Dir,
  [switch]$r,
  [switch]$Reload,
  [switch]$v,
  [switch]$Vim,
  [switch]$h,
  [switch]$Help
)

function Set-Profile {
  @(
    $Profile.AllUsersAllHosts,
    $Profile.AllUsersCurrentHost,
    $Profile.CurrentUserAllHosts,
    $Profile.CurrentUserCurrentHost
  ) | ForEach-Object {
    if (Test-Path $_) {
      Write-Verbose "Running $_"
      . $_
    }
  }
}

$helpDocument = @"
$PROFILE を編集するコマンド
prof         : Edit "$PROFILE" (default)

prof <option>

options:

-d, -Dir     : Enter directory.        $PROFILE ディレクトリに入ります
-r, -Reload  : Reload profile.         プロファイルを再読み込みします
-v, -Vim     : Open profile with vim.  neovimでプロファイルを開きます
-h, -Help    : Get help.               このヘルプを表示します
"@

if ($d -or $Dir) {
  if (Test-Path $PROFILE) {
    code "$HOME\dotfiles"
    return
  }
}
if ($r -or $Reload) {
  Set-Profile
  return
}
if ($v -or $Vim) {
  nvim "$HOME\dotfiles\windows\config\powershell-profile\profile.ps1"
  return
}
if ($h -or $Help) {
  Write-Host $helpDocument
  return
}

code "$HOME\dotfiles"
