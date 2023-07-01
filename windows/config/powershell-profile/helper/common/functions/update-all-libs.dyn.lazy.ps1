# Install global library
$Libs = @(

  $ScoopCachePath = ([IO.Path]::Combine($HOME, "scoop", "cache"))
  @{ name = "Scoop"; installer = "scoop update * && scoop cleanup * --cache;Get-ChildItem $ScoopCachePath -Include *.* -Recurse | Remove-Item" }
  @{ name = "corepack"; installer = "python3 -u `"$HOME/dotfiles/scripts/update-corepack.py`" --remove-prev --enabled" }
  @{ name = "npm"; installer = "npm up -g" }
  @{ name = "pnpm"; installer = "pnpm up -g" }
  @{ name = "deno"; installer = "deno upgrade" }
  @{ name = "PowerShell"; installer = "Update-Modules -Force" }
  @{ name = "cargo"; installer = "cargo install-update -a" }
  @{ name = "rustup"; installer = "rustup update" }

  # python
  @{ name = "pip-review"; installer = "pip-review -a" }
  @{ name = "pipx"; installer = "pipx upgrade-all" }

  # software(need sudo)
  @{ name = "scoop global"; installer = "sudo scoop update * --global && sudo scoop cleanup * --cache --global;Get-ChildItem $ScoopCachePath -Include *.* -Recurse | Remove-Item;" }
  @{ name = "winget"; installer = "sudo winget upgrade --all" }
)

foreach ($Lib in $Libs) {
  if ($Lib.name -Split " " | Get-Command -ErrorAction SilentlyContinue) {
    Write-Host "`n`n"
    Write-Host "$($Lib.name): " -NoNewline
    Write-Host "libs or itself is updating..." -ForegroundColor Blue
    $Lib.installer | Invoke-Expression
  }
}
