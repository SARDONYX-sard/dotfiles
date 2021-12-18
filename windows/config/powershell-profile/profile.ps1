#! use `CRLF` for powershell compatibility

$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";

. "$($HelperDir)/completion.ps1"
. "$($HelperDir)/functions.ps1"
. "$($HelperDir)/aliases.ps1"
. "$($HelperDir)/shell-design.ps1"

# Bell OFF
if ((Get-PSReadlineOption).BellStyle -eq "Audible") {
  Set-PSReadlineOption -BellStyle None
}

# --------------------------------------------------------------------------------------------------
# Module settings
# --------------------------------------------------------------------------------------------------


if ($PSVersionTable.PSEdition -eq "Core") {
  # Install-Module WslInterop
  Import-WslCommand "awk", "emacs", "fgrep", "egrep", "head", "less", "sed", "seq", "ssh", "tail", "man"#, "ls", "vim"
  $WslDefaultParameterValues = @{}
  $WslDefaultParameterValues["grep"] = "-E --color=auto"
  $WslDefaultParameterValues["less"] = "-i"
  $WslDefaultParameterValues["ls"] = "--color=auto --human-readable --group-directories-first"

  # PsFzf (This option is heavy processing.)
  Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }; # Tab completion
  # Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'  # Search for file paths in the current directory
  # Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' #  Search command history

  # fzf
  if ( Get-Command bat -ea 0 ) {
    $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"bat --pager=never --color=always --style=numbers --line-range :300 {}`""
    if ( Get-Command rg -ea 0 ) {
      $env:FZF_CTRL_T_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
    }
  }
  else {
    $env:FZF_DEFAULT_OPTS = "--tabstop=4 --preview `"cat {}`""
  }
}


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

# msys2
#! This statement must be at the end of the profile or the command will be lost for some reason.
#! Without this, msys2 will not inherit windows environment variables.
if (Get-Command msys2 -ea 0) { $env:MSYS2_PATH_TYPE = "inherit" }
