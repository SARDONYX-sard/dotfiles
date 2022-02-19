"""
ii ([IO.Path]::Combine($env:AppData, "Microsoft\\Windows\\Start Menu\\Programs\\Startup"))
"""

from os import name, system

if name == 'nt':
    system("pwsh -l -c update-all-libs")

elif name == 'posix':
    system("zsh -l -c update-all-libs")
