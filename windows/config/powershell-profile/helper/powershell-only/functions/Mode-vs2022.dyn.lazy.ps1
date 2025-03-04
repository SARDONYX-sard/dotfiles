# Enable clang, vcpkg path
# See: https://learn.microsoft.com/visualstudio/ide/reference/command-prompt-powershell?view=vs-2022
& { Import-Module $env:VS2022INSTALLDIR/Common7/Tools/Microsoft.VisualStudio.DevShell.dll; Enter-VsDevShell 3f90b5ca -SkipAutomaticLocation -Arch amd64 -HostArch amd64 }
