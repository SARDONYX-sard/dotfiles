# --------------------------------------------------------------------------------------------------
# Util
# --------------------------------------------------------------------------------------------------
function Set-Symlink {
  [CmdletBinding()]
  param (
    [string]$FromFileOrDirPath,
    [string]$ToFileOrDirPath,
    [hashtable]$Hash,
    [switch]$Force
  )
  $file = $null # Does not use ternary operators for `powershell compatibility`
  if ($Hash) { $file = $Hash }

  if ($File) {
    Write-Host ""
    Write-Host "now: $(Join-Path $file.path $file.name)"

    $fullPathName = Join-Path $file.path $file.name
    if (Test-Path $fullPathName) {
      Write-Host "Already exists." -ForegroundColor Blue
      if ($force) {
        Write-Host "Recreating..." -ForegroundColor Yellow
      (Get-Item $fullPathName).Delete()
      }
      else { return }
    }

    if (!(Test-Path $fullPathName)) {

      if (!(Test-Path ($file.path))) {
        mkdir ($file.path)
      }


      # Copy or SymbolicLink
      if ($file.mode -eq "copy") {
        Write-Host "Copying..." -ForegroundColor Green
        Copy-Item $file.target -Destination $file.path -Force
      }
      else {
        Write-Host "Making symbolic link..." -ForegroundColor Green

        #? Passing whitespace as a whole object will not result in a path error.
        New-Item -ItemType SymbolicLink @file | Out-Null
      }
      if (!$?) { Write-Error "${@file} is null. Failed to create symbolic link." }
    }

    return
  }

  Write-Host ""
  Write-Host "now: $(Join-Path $FromFileOrDirPath)"

  if (Test-Path $ToFileOrDirPath) {
    Write-Host "Already exists." -ForegroundColor Blue
    if ($force) {
      Write-Host "Recreating..." -ForegroundColor Yellow
        (Get-Item $fullPathName).Delete()
    }
    else { return }
  }

  if (!(Test-Path $ToFileOrDirPath)) {
    if (!(Test-Path ($ToDirPath))) { mkdir ($ToDirPath) }

    $name = Split-Path $ToFileOrDirPath -Leaf
    $ToDirPath = Split-Path $ToFileOrDirPath
    Write-Host "Making symbolic link..." -ForegroundColor Green
    New-Item -Value $FromFileOrDirPath -Path $ToDirPath -Name $Name -ItemType SymbolicLink | Out-Null
    if (!$?) { Write-Error "${@file} is null. Failed to create symbolic link." }
  }
}

# --------------------------------------------------------------------------------------------------
# All update
# --------------------------------------------------------------------------------------------------
function Update-AllLibs {
  Write-Host "Updating Scoop libraries..." -ForegroundColor Green
  s up
  s prune
  Write-Host "Updating npm libraries..." -ForegroundColor Green
  npm up -g
  Write-Host "Updating pnpm libraries..." -ForegroundColor Green
  pnpm update -g
  Write-Host "Updating python libraries..." -ForegroundColor Green
  pip-review -a
  Write-Host "Updating winget libraries..." -ForegroundColor Green
  wua
}


# --------------------------------------------------------------------------------------------------
# Anaconda3
# --------------------------------------------------------------------------------------------------
#region conda initialize
function ve ($cmd) {
  function Set-Activate {
    Write-Output "conda venv ($Args) enabled."
    return (& "conda.exe" "shell.powershell" "activate" $Args[0]) | Out-String | Invoke-Expression
  }

  function Set-Deactivate {
    Write-Output "conda venv disenabled."
    return (& "conda.exe" "shell.powershell" "deactivate") | Out-String | Invoke-Expression
  }

  $helpDocument = @"
Anaconda3 仮想環境(virtual environment)管理コマンド

ve <command>

Usage:

ve              : Enter base.  仮想環境(base)に入ります
ve <venv name>  : Activate.    仮想環境(作成済みの環境)に入ります
ve d            : Deactivate.  仮想環境から出ます
ve h            : Get help.    このヘルプを表示します
"@


  switch -Regex ($cmd) {
    "^(?:d|deactivate)$" { Set-Deactivate }
    "^(?:h|help)$" { Write-Output $helpDocument }
    Default {
      if ($Args[0]) {
        # !! Contents within this block are managed by 'conda init' !!
        Write-Output "Type 've h' to get help."
        Write-Output "conda venv (base) enabled."
        return (& "conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression
      }
      else {
        Set-Activate
      }

    }
  }
}
#endregions
