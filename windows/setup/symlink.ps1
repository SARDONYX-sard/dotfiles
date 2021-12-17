Param([switch]$f, [switch]$force, [switch]$d, [switch]$isDebug)
$force = $f.IsPresent -or $force.IsPresent
$isDebug = $d.IsPresent -or $isDebug.IsPresent

# Import SymLink function
$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";
. "$($HelperDir)/functions.ps1"


# Are you root?
if ($isDebug -eq $false) {
  if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
    exit $?
  }
}


# --------------------------------------------------------------------------------------------------
# Files
# --------------------------------------------------------------------------------------------------
<#
.NOTES
Specification

target(require):
  target is the actual directory or file. Relative or absolute path from `$HOME/dotfiles`
  (e.g.: "windows/config/.bashrc")
path(option):
  the directory where the symbolic link will be output
  (e.g.: "$HOME")
name(option):
  the name of the symbolic file
  (e.g.: ".bashrc")

1. If there is a path, combine it with the $HOME directory.
Example:

      @{ path = scoop/current }
      ↓
      @{ path = $HOME/scoop/current }


2. If there is fullpath If there is a fullpath, overwrite the string excluding the last path of the fullpath with overwrite path.
Example:

      @{ fullpath = windows/modules/dirs }
      ↓
      @{ path = windows/modules }

3. if there is no path or fullpath, path will contain $HOME
Example:

      @{ "windows/config/.bashrc" }
      ↓
      @{ target= "windows/config/.bashrc"; path = "$HOME/windows/config/.bashrc"; name= "bashrc" }

4. If you write it, only one of fullpath or path is needed.
#>

$pwshProfilePath = @($(pwsh -NoProfile -Command "`$profile"))[0]
$powerShellProfilePath = @($(powerShell -NoProfile -Command "`$profile"))[0]

$files = @(
  # vim
  @{ target = "init.vim"; path = ""; name = ".vimrc" }
  @{ target = "init.vim"; path = "AppData/Local/nvim" }
  @{ target = "ginit.vim"; path = "AppData/Local/nvim" }

  # Terminal
  $terminalPath = Join-Path $env:LocalAppData "Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
  $terminalPreviewPath = $terminalPath.Replace("Terminal", "TerminalPreview")
  @{ target = "windows\data\windows-terminal.json"; fullpath = $terminalPath; name = "settings.json" } # mode = "copy" }
  @{ target = "windows\data\windows-terminal-preview.json"; fullpath = $terminalPreviewPath; name = "settings.json" } # mode = "copy" }

  # AutoHotkey (Keyboard keyconfig)
  @{ target = "windows/config/init.ahk"; fullpath = Join-Path $env:AppData  "Microsoft/Windows/Start Menu/Programs/Startup/init.ahk" }

  # oh-my-posh theme (custom)
  @{ target  = "windows\data\oh-my-posh-themes\gmay.omp.json";
    fullpath = Join-Path (Split-Path (pwsh -NoProfile -Command "`$profile")) "\Modules\oh-my-posh\themes\gmay.omp.json"
  }
  @{ target  = "windows\data\oh-my-posh-themes\night-owl.omp.json";
    fullpath = Join-Path (Split-Path (pwsh -NoProfile -Command "`$profile")) "\Modules\oh-my-posh\themes\night-owl.omp.json"
  }

  # msys2 HomeDir
  $UserName = (Split-Path $HOME -Leaf)
  @{ target = $HOME; fullpath = Join-Path $HOME "scoop\apps\msys2\current\home\$UserName"; }

  "windows/config/.bash_profile"
  "windows/config/.bashrc"
)


# If you have a profile, add it and add it to $files.
if ( (Get-Command pwsh -ea 0) -and (pwsh -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/powershell-profile/profile.ps1"; fullpath = $pwshProfilePath })

  # create symlink from `pwsh's modules` to `powershell's modules`
  $pwshModulePath = $pwshProfilePath | Split-Path | Join-Path { $_ } "Modules" | Split-Path
  $powershellModulePath = $powerShellProfilePath | Split-Path | Join-Path { $_ } "Modules" | Split-Path
  $files += @(@{ target = $pwshModulePath; fullpath = $powershellModulePath; })
}

if ( (Get-Command powershell -ea 0) -and (powershell -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/powershell-profile/profile.ps1"; fullpath = $powerShellProfilePath })
}


# --------------------------------------------------------------------------------------------------
# Create Symbolic link
# --------------------------------------------------------------------------------------------------
function create_symlink($files) {
  if ($isDebug) {
    Write-Host "Debug mode is running..." -ForegroundColor Blue
    if (Test-Path result.txt) {
      Write-Host "result.txt already exists. Delete it." -ForegroundColor Yellow
      Remove-Item result.txt -Force
    }
  }
  else {
    Write-Host "Symbolic links mode is running..." -ForegroundColor Green
  }

  foreach ($file in $files) {
    if ($file.GetType() -eq [string]) {
      if (!$file) { continue }

      $file = @{target = $file; path = "" }
    }

    $isDrive = (Split-Path $file.target) -match "^[A-Z]:\\"
    if ($isDrive -eq $false) {
      $file.target = Join-Path "$HOME/dotfiles" $file.target
      if (!$file.name) { $file.name = Split-Path $file.target -Leaf }
    }


    if ( !$file.path ) { $file.path = "$HOME" }
    else { $file.path = Join-Path "$HOME" $file.path }

    if (!$file.name) { $file.name = Split-Path $file.path -Leaf }

    # Overwrite `path`& `name` property if `fullpath` is specified.
    if ($file.fullpath) {
      $file.name = Split-Path $file.fullpath -Leaf
      $file.path = Split-Path $file.fullpath
      $file.Remove("fullpath")
    }


    if ($isDebug) {
      Write-Output @file "`n" | Out-File result.txt -Append # for debug
      Write-Host @file "`n"
      continue
    }

    # Make symlink
    if (!(Test-Path $file.path)) {
      mkdir $file.path
    }
    if ($Force) { Set-SymLink -Hash $file -Force }
    else { Set-SymLink -Hash $file }
  }
}

create_symlink $files
