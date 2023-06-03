if ($isDebug -eq $false) {
  if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
      [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
    exit $?
  }
}

$os_version = $(Get-WmiObject Win32_OperatingSystem).Caption

if ($os_version -match "11") {
  dism /online /Enable-Feature /FeatureName:HypervisorPlatform
}
elseif ($os_version -match "10") {
  dism /online /Enable-Feature /FeatureName:Microsoft-Hyper-V-All
  dism /online /Enable-Feature /FeatureName:Container
}


wsl --update
wsl --shutdwon

winget install "docker desktop"

Restart-Computer
