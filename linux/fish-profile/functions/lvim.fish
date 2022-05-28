# Use lvim of windows, if the terminal is msys2.
if [ -e /c ]
    alias lvim="powershell.exe -c \"$HOME/.local/bin/lvim.ps1\""
end
