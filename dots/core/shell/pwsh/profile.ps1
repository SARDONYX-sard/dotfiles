# PowerShell profile for both pwsh 7 and Windows PowerShell 5.1.
# Shared aliases/env/PATH come from `dot gen` (~/.local/state/dot/gen/init.ps1).
#
# Rules:
# - 5.1-compatible syntax only (no `? :`, `??`, `` `e ``); 7-only features go under $IsCore.
# - Startup path uses .NET APIs and core language features only: the first use of a
#   Microsoft.PowerShell.Utility cmdlet (Write-Host, Select-Object, Register-EngineEvent,
#   ...) auto-loads that module and costs ~350ms. Heavy stuff runs on first idle.

$IsCore = $PSVersionTable.PSEdition -eq 'Core'
$DotGenDir = [IO.Path]::Combine($HOME, '.local', 'state', 'dot', 'gen')
if ([IO.File]::Exists("$DotGenDir/init.ps1")) { . "$DotGenDir/init.ps1" }   # also sets $env:DOT_ROOT
$DotPwshDir = [IO.Path]::Combine("$env:DOT_ROOT", 'dots', 'core', 'shell', 'pwsh')

# --- PSReadLine ---------------------------------------------------------------
# Vi mode only when DOT_EDIT_MODE=vi (shared.toml [env]); otherwise Emacs keys.
$IsViMode = $env:DOT_EDIT_MODE -eq 'vi'
Set-PSReadLineOption -EditMode $(if ($IsViMode) { 'Vi' } else { 'Emacs' }) -BellStyle None -HistoryNoDuplicates
Set-PSReadLineOption -AddToHistoryHandler {
  param($line)
  # Skip one-letter commands and lines tagged SKIPHISTORY.
  -not ($line -match '^[a-z]$' -or $line -match 'SKIPHISTORY')
}

if ($IsViMode) {
  Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
    # Cursor: blinking block (normal) / bar (insert). Mode letter: rewrite the 2nd
    # column of the input line (`+I$` / `+N$`, drawn by `prompt`) in place, so the
    # status line is not re-rendered. Skipped for multi-line input.
    $esc = [char]27
    $normal = $args[0] -eq 'Command'
    $line = $null; $cursor = 0
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    $letter = if ($normal) { "$esc[33mN" } else { "$esc[34mI" }
    $mark = if ($line.Contains("`n")) { '' } else { "${esc}7`r$esc[1C$letter$esc[0m${esc}8" }
    [Console]::Write($(if ($normal) { "$esc[1 q" } else { "$esc[5 q" }) + $mark)
  }

  # jj / jk -> normal mode (second key within 300ms of `j`).
  $global:JTimer = [Diagnostics.Stopwatch]::new()
  foreach ($key in 'j', 'k') {
    Set-PSReadLineKeyHandler -Key $key -ViMode Insert -ScriptBlock {
      param($k)
      $line = $null; $cursor = 0
      [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
      $afterJ = $cursor -gt 0 -and $line[$cursor - 1] -eq 'j'
      if ($afterJ -and $global:JTimer.IsRunning -and $global:JTimer.ElapsedMilliseconds -le 300) {
        $global:JTimer.Reset()
        [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 1)
        [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
        return
      }
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert([string]$k.KeyChar)
      if ($k.KeyChar -eq 'j') { $global:JTimer.Restart() } else { $global:JTimer.Reset() }
    }
  }
} # $IsViMode

Set-PSReadLineKeyHandler -Key 'alt+r' -BriefDescription 'reloadProfile' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('<#SKIPHISTORY#> . $PROFILE')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
Set-PSReadLineKeyHandler -Key 'alt+a' -BriefDescription 'yankLastArgAsVariable' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('$')
  [Microsoft.PowerShell.PSConsoleReadLine]::YankLastArg()
  $line = $null; $cursor = 0
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
  if ($line -match '\$\$') {
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $line.Length, ($line -replace '\$\$', '$'))
  }
}
Set-PSReadLineKeyHandler -Key 'ctrl+V' -BriefDescription 'clipboardToVariable' -ScriptBlock {
  [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert('<#SKIPHISTORY#> Get-Clipboard | Set-Variable CLIPPING')
  [Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory('$CLIPPING ')
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

# --- Prompt -------------------------------------------------------------------
# Plain PATH scan: Get-Command on a missing name triggers module auto-load
# discovery and can take >1s.
function Find-Exe([string]$Name) {
  $file = if ($env:OS -eq 'Windows_NT') { "$Name.exe" } else { $Name }
  foreach ($d in $env:PATH -split [IO.Path]::PathSeparator) {
    if ($d -and [IO.File]::Exists(($p = [IO.Path]::Combine($d, $file)))) { return $p }
  }
}
$global:DotBin = Find-Exe dot
# The `dot` prompt has a status line above the input line. Tell PSReadLine, or every
# InvokePrompt (e.g. returning from fzf/PSFzf key handlers) stacks another copy.
if ($global:DotBin) { Set-PSReadLineOption -ExtraPromptLineCount 1 }
$global:LsdBin = Find-Exe lsd
$global:LastDir = $PWD.Path
$global:DotPromptArgs = @('prompt', '--shell', 'pwsh', '--status-only')
$isAdmin = if ($env:OS -eq 'Windows_NT') {
  ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')
} else { [Environment]::UserName -eq 'root' }
# Input line `+-$ ` (box drawing chars): `-` becomes the vi mode letter (I/N, see
# ViModeChangeHandler). Non-ASCII is written as [char] codes: Windows PowerShell 5.1
# reads BOM-less scripts as the ANSI code page.
$global:DotInputLine = & {
  $esc = [char]27
  $mode = if ($IsViMode) { "$esc[34mI" } else { "$esc[32m$([char]0x2500)" } # each line starts in insert
  $mark = if ($isAdmin) { "$esc[31m#" } else { "$esc[36m$" }
  "$esc[32m$([char]0x2514)$mode$mark $esc[0m"
}

function prompt {
  $code = if ($?) { 0 } elseif ($LASTEXITCODE) { $LASTEXITCODE } else { 1 }
  $h = Get-History -Count 1
  $ms = if ($h) { [int]($h.EndExecutionTime - $h.StartExecutionTime).TotalMilliseconds } else { 0 }

  # Auto-ls after changing directory, whatever did the cd (zoxide, Set-Location, ...).
  if ($PWD.Path -ne $global:LastDir) {
    $global:LastDir = $PWD.Path
    if ($global:LsdBin) { & $global:LsdBin } else { Get-ChildItem | Format-Wide -AutoSize | Out-Host }
  }

  if ($global:DotBin) {
    # `dot` writes UTF-8, but pwsh decodes native output with the console code page
    # (CP932 in e.g. the VS Code terminal) -> mojibake. Decode as UTF-8 just here;
    # a global switch would break tools that print CP932 (ipconfig, ...).
    $enc = [Console]::OutputEncoding
    try {
      [Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
      $status = (& $global:DotBin @global:DotPromptArgs --status $code --duration $ms) -join "`n"
      "$status`n$global:DotInputLine"
    } finally {
      [Console]::OutputEncoding = $enc
    }
  } else {
    "PS $($PWD.Path)> "
  }
}

# --- Deferred: heavy modules load on first idle, after the prompt is shown -----
# Same as `Register-EngineEvent PowerShell.OnIdle -MaxTriggerCount 1`, without loading Utility.
$null = $ExecutionContext.Events.SubscribeEvent($null, $null, 'PowerShell.OnIdle', $null, {
  # zoxide, completions, ... (`lazy = true` in shared.toml) and own helpers.
  if ([IO.File]::Exists("$DotGenDir/init.lazy.ps1")) { . "$DotGenDir/init.lazy.ps1" }
  if ([IO.File]::Exists("$DotPwshDir/functions.ps1")) { . "$DotPwshDir/functions.ps1" }

  foreach ($m in 'npm-completion', 'WSLTabCompletion', 'WslInterop') {
    Import-Module $m -Global -ErrorAction Ignore
  }

  # PSFzf runs `fzf --version` on import. A native process started here (while
  # PSReadLine is already waiting for a key) swallows the first keystroke, so load
  # PSFzf on the first Ctrl+T / Ctrl+R / Tab instead and replay that key.
  if (Find-Exe fzf) {
    foreach ($k in 'ctrl+t', 'ctrl+r', 'Tab') {
      Set-PSReadLineKeyHandler -Key $k -BriefDescription 'psfzfLazy' -ScriptBlock {
        param($key, $arg)
        if (-not (Get-Module PSFzf)) {
          Import-Module PSFzf -Global -ErrorAction Ignore
          if (-not (Get-Module PSFzf)) {
            Set-PSReadLineKeyHandler -Key Tab -Function TabCompleteNext
            Set-PSReadLineKeyHandler -Key 'ctrl+r' -Function ReverseSearchHistory
            if ($key.Key -eq 'Tab') { [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext() }
            elseif ($key.Key -eq 'R') { [Microsoft.PowerShell.PSConsoleReadLine]::ReverseSearchHistory() }
            return
          }
          # PSFzf defaults to inline `--height=40%`: at the bottom of the window fzf scrolls
          # the screen, and PSFzf then redraws the prompt at the pre-scroll row (cursor
          # ends up off). 100% = fzf's fullscreen renderer, which restores the screen.
          # `_PSFZF_FZF_DEFAULT_OPTS` is read by PSFzf only, so other shells keep inline fzf.
          $env:_PSFZF_FZF_DEFAULT_OPTS = "$env:FZF_DEFAULT_OPTS --height=100%"
          Set-PsFzfOption -PSReadlineChordProvider 'ctrl+t' -PSReadlineChordReverseHistory 'ctrl+r'
          Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
        }
        switch ($key.Key) {
          'Tab' { Invoke-FzfTabCompletion }
          'T' { Invoke-FzfPsReadlineHandlerProvider }
          'R' { Invoke-FzfPsReadlineHandlerHistory }
        }
      }
    }
  }

  # pwsh 7 only: PSReadLine 2.1+ predictions.
  if ($IsCore) {
    Import-Module CompletionPredictor -Global -ErrorAction Ignore
    $source = if (Get-Module CompletionPredictor) { 'HistoryAndPlugin' } else { 'History' }
    Set-PSReadLineOption -PredictionSource $source
    if ($Host.UI.RawUI.WindowSize.Height -ge 15) { Set-PSReadLineOption -PredictionViewStyle ListView }
  }
}, $false, $false, 1)
