# Install-Module WslInterop
Import-WslCommand "awk", "emacs", "grep", "fgrep", "egrep", "head", "less", "sed", "seq", "ssh", "tail" # , "ls", "man", "vim"

Set-Alias c clear

# if ((Get-Process | Select-String docker)) {
#   Write-Warning "Docker & Kubernetes isn't running."
# }
# else {
#   Set-Alias kb kubectl
#   Set-Alias dc docker-compose
#   Set-Alias dk docker
# }
Set-Alias k kubectl
Set-Alias mk minikube
Set-Alias dc docker-compose
Set-Alias dk docker

Set-Alias bb Set-PrevLocation
Set-Alias ~ Move-HomeDir

Set-Alias g git
Set-Alias gen Get-SnippetGenerator
Set-Alias s scoop
Set-Alias w Get-Env
Set-Alias wget  Invoke-WebRequest

# like which alias
function Get-Env { which $args | Split-Path  | Invoke-Item }

function Set-PrevLocation { Set-Location -; Write-Host "Returned to previous directory." -ForegroundColor Blue }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function Move-HomeDir { Set-Location ~ }

function Get-SnippetGenerator { Start-Process https://snippet-generator.app/ }

function prof {
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

  if ($d -or $Dir) { pwsh -NoProfile -Command "`$profile" | Split-Path | code - -r }
  if ($r -or $Reload) { Set-Profile }
  if ($v -or $Vim) { nvim $PROFILE }
  if ($h -or $Help) { Write-Host $helpDocument }
  else { code $PROFILE }
}

function volume {
  Get-ChildItem `
  | Select-Object Name, @{ name = "Size"; expression = { `
        [math]::round((Get-ChildItem $_.FullName -Recurse -Force `
          | Measure-Object Length -Sum `
        ).Sum / 1MB ) `
    }
  }
}

# --------------------------------------------------------------------------------------------------
# git aliases
# --------------------------------------------------------------------------------------------------
function gitConf { git config --global -e }
function add { git add ${$} }
function cl($url) { git clone $url }
function cm { git commit ${$} }
function gil { git log }
function pull { git pull ${$} }
function push { git push ${$} }

# --------------------------------------------------------------------------------------------------
# treee(npm module) aliases
# --------------------------------------------------------------------------------------------------
function tree ($cmd) {
  $errorMsg = @"
Error:
該当するNodeモジュールがありません。以下のコマンドを実行し、tree-cliをインストールしてください
npm install -g tree-cli

・node.jsがない場合は、https://nodejs.org/ を参照してください
"@

  $helpMsg = @"
tree            : ソースツリーを実行します
tree o          : 第2層までのnode_modulesを除くtreeをtree.txtに書き込みます
tree h, help    : このヘルプを表示します
"@

  if ((Get-Command treee).Name -ne "treee.ps1") { Write-Host $errorMsg }

  switch ($cmd) {
    "o" { treee -l 2 --ignore 'node_modules' -o tree.txt }
    "node" { treee -l 2 --ignore 'node_modules' }
    "h" { Write-Output $helpMsg }
    "help" { Write-Output $helpMsg }
    Default { treee ${$} }
  }
}

# --------------------------------------------------------------------------------------------------
# winget aliases
# --------------------------------------------------------------------------------------------------
function wg ($cmd) {
  switch -Regex ($cmd) {
    "^(?:i|install)$" { winget install ${$} }
    "^(?:uni|uninstall)$" { winget uninstall ${$} }
    "^(?:s|search)$" { winget search ${$} }
    "^(?:ls|list)$" {
      if ($Args[0] -ne "") {
        winget list $Args[0]
      }
      else {
        winget list
      }
    }
    "^(?:up|upgrade)$" { winget upgrade ${$} }

    Default { winget $cmd }
  }
}

function wua { winget upgrade --all }

# --------------------------------------------------------------------------------------------------
# wsl aliases
# --------------------------------------------------------------------------------------------------
# ls aliases
function ll() { wsl ls -alF }

function la() { wsl ls -A }

function l() { wsl ls -CF }

$WslDefaultParameterValues = @{}
$WslDefaultParameterValues["grep"] = "-E --color=auto"
$WslDefaultParameterValues["less"] = "-i"
$WslDefaultParameterValues["ls"] = "--color=auto --human-readable --group-directories-first"

# Set-ToLF
function tolf($extension) {
  if ($extension) {
    return Get-ChildItem -Recurse -File -Filter *.$extension
    | ForEach-Object { ((Get-Content $_.FullName -Raw) -replace "`r`n", "\`n")
    | Set-Content -encoding UTF8 -NoNewline $_.FullName }
  }

  Get-ChildItem -Recurse -File
  | ForEach-Object { ((Get-Content $_.FullName -Raw) -replace "`r`n", "\`n")
  | Set-Content -encoding UTF8 -NoNewline $_.FullName }
}

function su {
  if ( Get-Command pwsh -ea 0 ) {
    Start-Process pwsh -Verb RunAs
  }
  elseif ( Get-Command powershell -ea 0 ) {
    Start-Process powershell -Verb RunAs
  }
}

# --------------------------------------------------------------------------------------------------
# PowerShell Prompt(Kali-Linux like)
# --------------------------------------------------------------------------------------------------
function Prompt {
  $promptString = "PowerShell " + $(Get-Location) + ">"
  $isAdmin = '$'
  if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $isAdmin = '#'
  }
  # Custom color for Windows console
  if ( $Host.Name -eq "ConsoleHost" ) {
    Write-Host ("┌──[") -nonewline -foregroundcolor DarkGreen
    write-host (Get-ShortenPath([string] (Get-Location).Path)) -nonewline -foregroundcolor White
    Write-Host ("]") -nonewline -foregroundcolor Green
    Write-Host (" ") -nonewline
    Write-Host (Get-Date -Format g) -nonewline -foregroundcolor yellow
    Write-Host (" ") -nonewline
    Write-Host ("[") -nonewline -foregroundcolor DarkGreen
    Write-Host ($env:username) -nonewline -foregroundcolor DarkCyan
    Write-Host ("@") -nonewline -foregroundcolor yellow
    Write-Host (hostname) -NoNewline -ForegroundColor DarkCyan
    Write-Host ("]") -nonewline -foregroundcolor DarkGreen
    Write-Host (" ") -foregroundcolor DarkGray

    Write-Host ("└─") -nonewline -foregroundcolor DarkGreen
    Write-Host ($isAdmin) -nonewline -foregroundcolor DarkCyan
  }
  # Default color for the rest
  else {
    Write-Host $promptString -NoNewline
  }

  return " "
}
function Get-ShortenPath([string] $path) {
  # 1. Replace home path to "~"
  # 2. remove prefix for UNC paths
  # 3. make path shorter like tabs in Vim, handle paths starting with \ and . correctly
  return $path.Replace($HOME, '~').Replace('^[^:]+::', '').Replace('\(.?)([^\])[^\]*(?=\)', '$1$2')
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
    return (& "conda.exe" "shell.powershell" "deactivate")
    | Out-String | Invoke-Expression
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


# --------------------------------------------------------------------------------------------------
# PowerShell Prompt Theme
# --------------------------------------------------------------------------------------------------
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt Paradox
Set-PoshPrompt -Theme 'gmay'

$env:RunFromPowershell = 1


# --------------------------------------------------------------------------------------------------
# Remove vim env
# --------------------------------------------------------------------------------------------------
$env_to_del = @(
  "VIM"
  "VIMRUNTIME"
  "MYVIMRC"
  "MYGVIMRC"
)

foreach ($var in $env_to_del) {
  Remove-Item env:$var -ErrorAction SilentlyContinue
}


# -- fzf の設定
if ( Get-Command bat -ea 0 ) {
  $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"bat --pager=never --color=always --style=numbers --line-range :300 {}`""
}
else {
  $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"cat {}`""
}
