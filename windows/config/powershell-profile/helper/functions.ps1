# --------------------------------------------------------------------------------------------------
# Util
# --------------------------------------------------------------------------------------------------
function bo {
  broot --conf $HOME/dotfiles/common/data/broot-config.toml -s -g -h -F $args
}

function br() {
  $outcmd = New-TemporaryFile
  bo --outcmd $outcmd $args
  if (!$?) {
    Remove-Item -Force $outcmd
    return $lastexitcode
  }

  $command = Get-Content $outcmd
  if ($command) {
    # workaround - paths have some garbage at the start
    $command = $command.replace("\\?\", "", 1)
    Invoke-Expression $command
  }
  Remove-Item -Force $outcmd
}


# --------------------------------------------------------------------------------------------------
# Util
# --------------------------------------------------------------------------------------------------
function color {
  # https://stackoverflow.com/questions/20541456/list-of-all-colors-available-for-powershell
  $colors = [enum]::GetValues([System.ConsoleColor])
  Foreach ($bgcolor in $colors) {
    Foreach ($fgcolor in $colors) { Write-Host "$fgcolor|"  -ForegroundColor $fgcolor -BackgroundColor $bgcolor -NoNewline }
    Write-Host " on $bgcolor"
  }
}

function add-vim-setting {
  "if !has('zsh')
  set shell=pwsh
endif" >> $HOME\dotfiles\init.vim
}

function printenv {
  Get-ChildItem Env:
}

function Set-Env {
  [CmdletBinding()]
  param (
    [string] $Key = "path",
    [Parameter(Mandatory = $true,
      ValueFromPipeline = $true)]
    [string] $Value
  )
  [System.Environment]::SetEnvironmentVariable($Key, "$Value" + [System.Environment]::GetEnvironmentVariable('path', "User"), "User")

  if ($?) { Write-Host "Set-Env: $Key += $Value" }
  else { Write-Host "Set-Env: $Key += $Value failed" }
}

function Get-Path {

  $toReplaceStr = ";

"
  [regex]::Replace($ENV:PATH, ";", "$toReplaceStr") | Sort-Object | Write-Host
}

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

function Get-PCInfo() {
  # System Information
  $ReturnData = New-Object PSObject | Select-Object HostName, Manufacturer, Model, SN, CPUName, PhysicalCores, Sockets, MemorySize, DiskInfos, OS

  $Win32_BIOS = Get-WmiObject Win32_BIOS
  $Win32_Processor = Get-WmiObject Win32_Processor
  $Win32_ComputerSystem = Get-WmiObject Win32_ComputerSystem
  $Win32_OperatingSystem = Get-WmiObject Win32_OperatingSystem

  $ReturnData.HostName = hostname

  # Maker Name
  $ReturnData.Manufacturer = $Win32_BIOS.Manufacturer

  # Motherboard Model
  $ReturnData.Model = $Win32_ComputerSystem.Model

  $ReturnData.SN = $Win32_BIOS.SerialNumber

  $ReturnData.CPUName = @($Win32_Processor.Name)[0]

  $PhysicalCores = 0
  $Win32_Processor.NumberOfCores | ForEach-Object { $PhysicalCores += $_ }
  $ReturnData.PhysicalCores = $PhysicalCores

  $ReturnData.Sockets = $Win32_ComputerSystem.NumberOfProcessors

  $Total = 0
  Get-WmiObject -Class Win32_PhysicalMemory | ForEach-Object { $Total += $_.Capacity }
  $ReturnData.MemorySize = [int]($Total / 1GB)

  # DiskInfos
  [array]$DiskDrives = Get-WmiObject Win32_DiskDrive | Where-Object { $_.Caption -notmatch "Msft" } | Sort-Object Index
  $DiskInfos = @()
  foreach ( $DiskDrive in $DiskDrives ) {
    $DiskInfo = New-Object PSObject | Select-Object Index, DiskSize
    $DiskInfo.Index = $DiskDrive.Index
    $DiskInfo.DiskSize = [int]($DiskDrive.Size / 1GB)
    $DiskInfos += $DiskInfo
  }
  $ReturnData.DiskInfos = $DiskInfos

  $OS = $Win32_OperatingSystem.Caption
  $SP = $Win32_OperatingSystem.ServicePackMajorVersion
  if ( $SP -ne 0 ) { $OS += "SP" + $SP }
  $ReturnData.OS = $OS

  return $ReturnData
}

function wk { fzwiki $args  -l ja }

function update-all-libs {
  # Install global library
  $Libs = @(
    # JavaScript
    $ScoopCachePath = ([IO.Path]::Combine($HOME, "scoop", "cache"))
    @{ name = "Scoop"; installer = "scoop update *;scoop cleanup * --cache;Get-ChildItem $ScoopCachePath -Include *.* -Recurse | Remove-Item" }
    @{ name = "corepack"; installer = "python3 -u `"$HOME/dotfiles/scripts/corepack-update.py`"" }
    @{ name = "npm"; installer = "npm up -g" }
    @{ name = "pnpm"; installer = "pnpm up -g" }
    @{ name = "deno"; installer = "deno upgrade" }
    @{ name = "PowerShell"; installer = "Update-Module -Force" }
    @{ name = "cargo"; installer = "cargo install-update -a" }

    # python
    @{ name = "pip-review"; installer = "pip-review -a" }
    @{ name = "pipx"; installer = "pipx upgrade-all" }

    # software
    @{ name = "need sudo (scoop, windget)"; installer = "sudo scoop update * --global && winget upgrade --all;" }
  )

  foreach ($Lib in $Libs) {
    Write-Host "`n`n"
    Write-Host "$($Lib.name): " -NoNewline
    Write-Host "libs or itself is updating..." -ForegroundColor Blue
    $Lib.installer | Invoke-Expression
  }
}

function to4k () {
  param (
    [Parameter()]
    [String]$i,
    [String]$ImagePath = $i,
    [String]$o = "./output/$(Split-Path $i -Leaf)",
    [String]$OutputPath = $o
  )
  mkdir -p $(Split-Path $OutputPath)
  Write-Host "Output path: $OutputPath"
  waifu2x-ncnn-vulkan -i $ImagePath -o $OutputPath -n 2 -s 2
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
# python
# --------------------------------------------------------------------------------------------------
function pips() { pip_search $args };

# Anaconda3
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
