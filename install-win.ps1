Write-Host "Installing Windows development environment..." -ForegroundColor Green

try {
  # Install scoop(https://scoop.sh/)
  Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
}
catch {
  powershell -ExecutionPolicy RemoteSigned -File "./install-win.ps1"
}

# For sudo, say, gitignore, etc commands. (https://github.com/lukesampson/psutils)
scoop install psutils

sudo Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/SARDONYX-sard/dotfiles/main/windows/install-app.ps1')
