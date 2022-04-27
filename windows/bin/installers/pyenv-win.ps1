<#
.SYNOPSIS
  Short description
.DESCRIPTION
  ref: https://github.com/pyenv-win/pyenv-win#installation
.EXAMPLE
  - Enable python lists
    pyenv install -l

  - Install python
    pyenv install 3.10.2

  - Set python version
    pyenv global 3.10.2
#>

git clone https://github.com/pyenv-win/pyenv-win.git "$HOME/.pyenv"

[System.Environment]::SetEnvironmentVariable('PYENV', $env:USERPROFILE + "\.pyenv\pyenv-win\", "User")
[System.Environment]::SetEnvironmentVariable('PYENV_ROOT', $env:USERPROFILE + "\.pyenv\pyenv-win\", "User")
[System.Environment]::SetEnvironmentVariable('PYENV_HOME', $env:USERPROFILE + "\.pyenv\pyenv-win\", "User")

[System.Environment]::SetEnvironmentVariable('path', $env:USERPROFILE + "\.pyenv\pyenv-win\bin;" + $env:USERPROFILE + "\.pyenv\pyenv-win\shims;" + [System.Environment]::GetEnvironmentVariable('path', "User"), "User")
Set-Location $HOME
pyenv rehash # For python module scripts enabled

sudo ln -s $HOME\.pyenv\pyenv-win\shims $HOME\.pyenv\shims # for init.vim settings
