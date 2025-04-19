# Enable clang, vcpkg path
# See: https://learn.microsoft.com/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022
#
# https://stackoverflow.com/questions/68635853/how-do-i-get-visual-studio-developer-powershell-working-in-visual-studio-codes
$vsPath = &(Join-Path 'C:\\Program Files (x86)' '\\Microsoft Visual Studio\\Installer\\vswhere.exe') -property installationpath; Import-Module (Join-Path $vsPath 'Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll'); Enter-VsDevShell -VsInstallPath $vsPath -SkipAutomaticLocation -Arch amd64 -HostArch amd64
