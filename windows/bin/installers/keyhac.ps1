# -- install keyhac

# Are you root?
if ($isDebug -eq $false) {
  if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
    exit $?
  }
}

$DownLoadPath = "$HOME/myapps/keyhac.zip"
$DistPath = "$HOME/myapps"
mkdir -p $DistPath;

if (Test-Path $DownLoadPath) {
  Write-Host "keyhac.zip exists."
}
else {
  Write-Host "Downloading keyhac.zip..."
  $url = "http://crftwr.github.io/keyhac/download/keyhac_182.zip"
  (New-Object System.Net.WebClient).DownloadFile($url, $DownLoadPath);
}

if (Test-Path $DistPath) {
  Write-Warning "$DistPath already exists.";
}
else {
  Expand-Archive -Path $DownLoadPath -DestinationPath $DistPath;
}

New-Item -ItemType SymbolicLink -Target "$DistPath\keyhac\keyhac.exe" -Path "$([IO.Path]::Combine($env:AppData, "Microsoft/Windows/Start Menu/Programs/Startup"))" -Name "keyhac.exe" | Out-Null
