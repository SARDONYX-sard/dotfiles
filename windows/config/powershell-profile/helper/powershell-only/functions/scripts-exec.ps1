function Reset-Scoop {
  pwsh -ExecutionPolicy ByPass -File "$HOME/dotfiles/scripts/reset-scoop.ps1"
}

function Update-Corepack {
  python3 "$HOME/dotfiles/scripts/update-corepack.py"
}
