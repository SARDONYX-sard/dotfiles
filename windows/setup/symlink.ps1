Param([switch]$f, [switch]$force)

$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";
. "$($HelperDir)/functions.ps1"

Write-Host "Linking Symbolic links..." -ForegroundColor Green

$force = $f.IsPresent -or $force.IsPresent

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
      [Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
  exit $?
}

$terminalPath = Join-Path $env:LocalAppData "Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
$terminalPreviewPath = $terminalPath.Replace("Terminal", "TerminalPreview")

$files = @(
  # vim
  @{ target = "init.vim"; path = ""; name = ".vimrc" }
  @{ target = "init.vim"; path = "AppData/Local/nvim" }
  @{ target = "ginit.vim"; path = "AppData/Local/nvim" }

  # Terminal
  @{ target = "windows\data\windows-terminal\settings.json"; fullpath = $terminalPath; } # mode = "copy" }
  @{ target = "windows\data\windows-terminal-preview\settings.json"; fullpath = $terminalPreviewPath; } # mode = "copy" }

  @{ target = "windows/config/init.ahk"; fullpath = Join-Path $env:AppData  "Microsoft/Windows/Start Menu/Programs/Startup/init.ahk" }

  # oh-my-posh theme (custom)
  @{ target  = "windows\data\custom-oh-my-posh\themes\gmay.omp.json";
    fullpath = Join-Path (Split-Path (pwsh -NoProfile -Command "`$profile")) "\Modules\oh-my-posh\themes\gmay.omp.json"
  }
  @{ target  = "windows\data\custom-oh-my-posh\themes\night-owl.omp.json";
    fullpath = Join-Path (Split-Path (pwsh -NoProfile -Command "`$profile")) "\Modules\oh-my-posh\themes\night-owl.omp.json"
  }

  "windows/config/.bash_profile"
  "windows/config/.bashrc"
)

# If you have a profile, add it and add it to $files.
if ( (Get-Command pwsh -ea 0) -and (pwsh -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/powershell-profile/profile.ps1"; fullpath = @($(pwsh -NoProfile -Command "`$profile"))[0] })
}

if ( (Get-Command powershell -ea 0) -and (powershell -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/powershell-profile/profile.ps1"; fullpath = @($(powershell -NoProfile -Command "`$profile"))[0] })
}


# ------------------------------------------------------------------------------------------------
# Create Symbolic link
# ------------------------------------------------------------------------------------------------
foreach ($file in $files) {
  if ($file.GetType() -eq [string]) {
    if (!$file) { continue }

    $file = @{target = $file; path = "" }
  }

  $isDrive = (Split-Path $file.target) -match "^C:\\"
  if ($isDrive -ne $true) {
    $target_name = Split-Path $file.target -Leaf
    $file.target = Join-Path "$HOME/dotfiles" $file.target
  }

  if ( !$file.path ) { $file.path = "$HOME" }
  else { $file.path = Join-Path "$HOME" $file.path }

  if ($file.fullpath) {
    $file.path = Split-Path $file.fullpath
    $name = Split-Path $file.fullpath -Leaf
    if ($name) {
      $file.name = $name
    }
    $file.Remove("fullpath")
  }

  if (!$file.ContainsKey("name")) { $file.name = $target_name }

  if (!(Test-Path $file.path)) {
    mkdir $file.path
  }

  if ($Force) { Set-SymLink -Hash $file -Force }
  else { Set-SymLink -Hash $file }
  # Write-Output @file | Out-File result.txt -Append # for debug
}

# create symlink from `pwsh's modules` to `powershell's modules`
$pwshModulePath = @($(pwsh -NoProfile -Command "`$profile"))[0] | Split-Path | Join-Path { $_ } "Modules" | Split-Path
$powershellPath = @($(powershell -NoProfile -Command "`$profile"))[0] | Split-Path

# msys2 HomeDir
$UserName = (Split-Path $HOME -Leaf)

if ($Force) {
  Set-SymLink -Hash @{ target = $HOME; path = Join-Path $HOME "scoop\apps\msys2\current\home\$UserName"; } -Force
  Set-SymLink -Hash @{ target = $pwshModulePath; path = $powershellPath; name = "Modules" } -Force
}
else {
  Set-SymLink -Hash @{ target = $pwshModulePath; path = $powershellPath; name = "Modules" }
  Set-SymLink -Hash @{ target = $HOME; path = Join-Path $HOME "scoop\apps\msys2\current\home\$UserName"; }
}
