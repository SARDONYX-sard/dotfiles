# --------------------------------------------------------------------------------------------------
# Aliases
# --------------------------------------------------------------------------------------------------
# Virtual machine
Set-Alias k k9s
Set-Alias dc docker-compose
Set-Alias dk docker

# Move directory
Set-Alias ~~ Move-HomeDir

# Utils
Set-Alias c clear
Set-Alias g git
Set-Alias gen Get-SnippetGenerator
Set-Alias s scoop
Set-Alias wh which

# Node.js
Set-Alias n npm
Set-Alias pn pnpm
Set-Alias y yarn

#! Only pwsh is enabled because powershell cannot overwrite existing aliases.
# Instead of commnad by Rust
# The sd command is not registered as an alias because it is not compatible.
if ($PSVersionTable.PSEdition -eq "Core") {
  Set-Alias cat bat
  Set-Alias dig dog
  Set-Alias find fd
  Set-Alias grep rg
  Set-Alias ls lsd
  Set-Alias ps procs
}

# --------------------------------------------------------------------------------------------------
# Functions for realizing aliases.
# --------------------------------------------------------------------------------------------------
function which {
  param (
    [switch]$d,
    [switch]$Detail,
    [switch]$v,
    [switch]$Verbose
  )

  $result = (Get-Command $args)
  if ($result.CommandType -eq "Alias") {
    $result = Get-Command $result.Definition
  }

  if ($d -or $Detail) {
    return $result
  }
  elseif ($v -or $Verbose) {
    return $result | Format-List
  }

  $path = $result.Definition

  if ($path -match "shims") { $path = scoop which $args } # Solving the scoop path display problem
  $path
}

#? Dependency injection with the idea of using zoxide
function cdFunc { Invoke-Expression -Command "cd $args" }

# which open directory environment path
function w ($cmd) { which $cmd | Split-Path | Invoke-Item }

function bb { cdFunc - ; Write-Host "Back to previous directory." -ForegroundColor Green }
function .. { cdFunc .. }
function ... { cdFunc ../.. }
function .... { cdFunc ../../.. }
function Move-HomeDir { cdFunc ~ }

function Get-SnippetGenerator { Start-Process https://snippet-generator.app/ }

function prog { cdFunc "D:\Programing\" }

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
}

function volume {
  Get-ChildItem `
  | Select-Object Name, @{ name = "Size"; expression = { `
        [math]::round((Get-ChildItem $_.FullName -Recurse -Force `
          | Measure-Object Length -Sum `
        ).Sum / 1.0MB ).ToString() + " MiB" `
    }
  }
}

# --------------------------------------------------------------------------------------------------
# git aliases
# --------------------------------------------------------------------------------------------------
function gitConf { git config --global -e }
function add { git add $args }
function cl { git clone $args }
function cm { git commit $args }
function gil { git log }
function pull { git pull $args }
function push { git push $args }

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
tree o          : 第2層までのnode_modulesを除くtreeを、tree.txtとして書き込みます
tree h, help    : このヘルプを表示します


--help       :詳細な使用状況を出力します。
--version    : tree-cli のバージョンを出力します。
--debug      : デバッグ情報を表示します。
--fullpath   : 各ファイルのフルパス・プレフィックスを表示します。
--ignore     : 指定したディレクトリやファイルを無視します - 配列をカンマ区切りの文字列(e.g.: 'node_modules/, .git/, .gitignore')として受け取ります
--link       : シンボリックリンクがディレクトリを指している場合、ディレクトリであるかのようにそれに従います。再帰を引き起こすシンボリックリンクは検出された時点で回避されます。
--noreport   : ツリー一覧の最後にファイルとディレクトリのレポートを表示することを省略し、コンソールへのツリーの表示を省略します。
--base       : ルートディレクトリを指定します。cwd rootからの相対パスでも、絶対パスでも構いません。この引数はオプションです。
-a           : すべてのファイルを表示します。デフォルトでは、tree は隠しファイル (ドット '.' で始まるファイル) を表示しません。
              また、ファイルシステムの構造体である '.' (現在のディレクトリ) と '..' (前のディレクトリ) を表示することはありません。
              (前のディレクトリ)を表示しません。
-d           : ディレクトリのみをリストアップします。
-f           : ディレクトリには '/'、ソケットファイルには '='、FIFO には '|' を付加します。
-i           :ツリーにインデント行を表示しないようにします。-fオプションと併用すると便利です。
-l           : ディレクトリツリーの最大表示深度を指定します。
-o           : 出力をファイル名に送ります。
"@

  if ((Get-Command treee).Name -ne "treee.ps1") { Write-Host $errorMsg }

  switch ($cmd) {
    "o" { treee -l 2 --ignore 'node_modules' -o ./tree.txt }
    "node" { treee -l 2 --ignore 'node_modules' }
    "h" { Write-Output $helpMsg }
    "help" { Write-Output $helpMsg }
    Default { treee $args }
  }
}

# --------------------------------------------------------------------------------------------------
# winget aliases
# --------------------------------------------------------------------------------------------------
function wg ($cmd) {
  switch -Regex ($cmd) {
    "^(?:i|install)$" { winget install $args }
    "^(?:uni|uninstall)$" { winget uninstall $args }
    "^(?:s|search)$" { winget search $args }
    "^(?:ls|list)$" {
      if ($Args[0] -ne "") {
        winget list $Args[0]
      }
      else {
        winget list
      }
    }
    "^(?:up|upgrade)$" { winget upgrade $args }

    Default { winget $cmd }
  }
}

function wua { sudo winget upgrade --all }

function tolf($extension) {
  if ($extension) {
    return Get-ChildItem -Recurse -File -Filter *.$extension |
    ForEach-Object { (([System.IO.File]::ReadAllText($_.FullName)) -replace "`r`n", "\`n") |
      Set-Content -Encoding UTF8 -NoNewline $_.FullName }
  }

  Get-ChildItem -Recurse -File `
  | ForEach-Object { (([System.IO.File]::ReadAllText($_.FullName)) -replace "`r`n", "\`n") `
    | Set-Content -Encoding UTF8 -NoNewline $_.FullName }
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
# Linux aliases
# --------------------------------------------------------------------------------------------------
# ls aliases
if (Get-Command lsd) {
  function l() { lsd -F $args } # Append indicator `F`
  function la() { lsd -aF $args } # show dotfile `a`, Append indicator `F`
  function ll() { lsd -lF $args } # list permission status `l`, Append indicator `F`
  function lla() { lsd -alF $args } # show dotfile `a`, list permission status `l`, Append indicator `F`
}

# coreutils (by Rust)
function tail { coretutils tail $args }
function head { coretutils head $args }
function seq { coretutils seq $args }
