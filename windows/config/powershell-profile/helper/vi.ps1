Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -HistoryNoDuplicates # https://github.com/PowerShell/PSReadLine/blob/master/PSReadLine/SamplePSReadLineProfile.ps1

if ($PSVersionTable.PSEdition -eq "Core") {
  Set-PSReadLineOption -PredictionSource HistoryAndPlugin
  # For VSCode terminal
  if ($Host.UI.RawUI.WindowSize.Height -ge 15) {
    Set-PSReadLineOption -PredictionViewStyle ListView
  }
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
  $env:EDITOR = $env:VISUAL = 'nvim'
}

# ref: https://github.com/PowerShell/PSReadLine/issues/3159
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler {
  $ESC = "$([char]0x1b)"
  if ($args[0] -eq 'Command') {
    Write-Host -NoNewline "${ESC}[1 q" # Set the cursor to a blinking block.
    return
  }
  Write-Host -NoNewline "${ESC}[5 q" # Set the cursor to a blinking line.
}

# DeBounce insert mode to normal mode.(insert mode -> "jj" or "jk" -> normal mode)
# https://github.com/PowerShell/PSReadLine/issues/1701
$local:j_timer = New-Object System.Diagnostics.Stopwatch
function Set-DebounceChangeMode {
  Set-PSReadLineKeyHandler -Key "j" -ViMode Insert -ScriptBlock {
    if (!$j_timer.IsRunning -or $j_timer.ElapsedMilliseconds -gt 300) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("j")
      $j_timer.Restart()
      return
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("j")
    [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
    $local:line = $null
    $local:cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 2)
  }

  Set-PSReadLineKeyHandler -Key "k" -ViMode Insert -ScriptBlock {
    if (!$j_timer.IsRunning -or $j_timer.ElapsedMilliseconds -gt 300) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert("k")
      return
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
    $local:line = $null
    $local:cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor, 1)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
  }
}
Set-DebounceChangeMode
