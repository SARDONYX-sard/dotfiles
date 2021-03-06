function update-all-libs {
  # Install global library
  $Libs = @(
    # JavaScript
    $ScoopCachePath = ([IO.Path]::Combine($HOME, "scoop", "cache"))
    @{ name = "Scoop"; installer = "scoop update *;scoop cleanup * --cache;Get-ChildItem $ScoopCachePath -Include *.* -Recurse | Remove-Item" }
    @{ name = "corepack"; installer = "python3 -u `"$HOME/dotfiles/scripts/update-corepack.py`"" }
    @{ name = "npm"; installer = "npm up -g" }
    @{ name = "pnpm"; installer = "pnpm up -g" }
    @{ name = "deno"; installer = "deno upgrade" }
    @{ name = "PowerShell"; installer = "Update-Module -Force" }
    @{ name = "cargo"; installer = "cargo install-update -a" }

    # python
    @{ name = "pip-review"; installer = "pip-review -a" }
    @{ name = "pipx"; installer = "pipx upgrade-all" }

    # software
    @{ name = "need sudo (scoop, windget)"; installer = "sudo scoop update * --global && winget upgrade --all;" }
  )

  foreach ($Lib in $Libs) {
    Write-Host "`n`n"
    Write-Host "$($Lib.name): " -NoNewline
    Write-Host "libs or itself is updating..." -ForegroundColor Blue
    $Lib.installer | Invoke-Expression
  }
}
