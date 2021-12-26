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

  if ($file) {
    $PathName = [IO.Path]::Combine($file.path, $file.name)
    Write-Host ""
    Write-Host "now: $($PathName)"

    $fullPathName = $PathName
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
  Write-Host "now: $FromFileOrDirPath"

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
# Convinience functions
# --------------------------------------------------------------------------------------------------
function Update-AllLibs {
  # --------------------------------------------------------------------------------------------------
  # Install global library
  # --------------------------------------------------------------------------------------------------
  $Libs = @(
    # JavaScript
    $ScoopCachePath = ([IO.Path]::Combine($HOME, "scoop", "cache"))
    @{ name = "Scoop"; installer = "scoop update *;scoop cleanup * --cache;Get-ChildItem $ScoopCachePath -Include *.* -Recurse | Remove-Item" }
    @{ name = "npm"; installer = "npm up -g" }
    @{ name = "pnpm"; installer = "pnpm up -g" }
    @{ name = "deno"; installer = "deno upgrade" }

    # python
    @{ name = "pip-review"; installer = "pip-review -a" }
    @{ name = "pipx"; installer = "pipx upgrade-all" }

    # Software
    @{ name = "winget"; installer = "scoop reset python;sudo winget upgrade --all; scoop reset python38" }
  )

  foreach ($Lib in $Libs) {
    Write-Host "`n`n"
    Write-Host "$($Lib.name): " -NoNewline
    Write-Host "libs or itself is updating..." -ForegroundColor Blue
    $Lib.installer | Invoke-Expression
  }
}

function Convert-Img {
  param (
    [Parameter()]
    [String]$p = "*.png",
    [String]$ImagePath,
    [String]$o = "jpg",
    [String]$Output,
    [Switch]$h,
    [Switch]$Help
  )

  if ( Get-Command magisk -ea 0 ) {
    Write-Error @"
    ImageMagick not installed. Please following the commands.

    scoop install imagemagick
"@
  }

  if ($Help) {
    Write-Host @"
    Convert image to other format.

    Usage:
      Convert-Img [options] [path]

    Options:
      -p, --path     [string]  Path to image. glob or a file. default: *.png
      -o, --output   [string]  Output format. default: jpg
      -h, --help     [switch]  Show help.
"@
  }

  if ($p) { $ImagePath = $p }
  if ($o) { $Output = $o }

  $images = Get-ChildItem -Path $ImagePath -Recurse | Write-Output
  foreach ($image in $images) {
    $OutputFile = [io.path]::ChangeExtension($image, $o)
    magick $image  $OutputFile
  }
}

function Get-PoshThemesAll {
  $ThemesPath = [IO.Path]::Combine("$(which oh-my-posh | Split-Path | Split-Path)", "themes")
  if (($null -eq $ThemesPath) -or !(Test-Path $ThemesPath) ) {
    Write-Host "Themes path not found." -ForegroundColor Red
    return
  }
  Get-PoshThemes -Path $ThemesPath
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
