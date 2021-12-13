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
