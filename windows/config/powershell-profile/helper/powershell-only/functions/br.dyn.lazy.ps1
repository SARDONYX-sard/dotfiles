<#
  broot(directory visiter written by Rust) command wrapper
#>
if (Get-Command broot -ErrorAction SilentlyContinue) {
  function bo { broot --conf $HOME/dotfiles/common/data/broot-config.toml -s -g -h -F $args }

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
