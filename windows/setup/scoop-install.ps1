# --------------------------------------------------------------------------------------------------
# Aliases(to like pnpm commands) reference: JP(https://qiita.com/nimzo6689/items/53c63439f56ccd2d38c1)
# --------------------------------------------------------------------------------------------------
# install
scoop alias add i 'scoop install $args[0]' 'Install Scoop apps.'
scoop alias add add 'scoop install $args[0]' 'Install Scoop apps.'

# uninstall
scoop alias add uni 'scoop uninstall $args[0]' 'Remove Scoop apps.'
scoop alias add rm 'scoop uninstall $args[0]' 'Remove Scoop apps.'
scoop alias add remove 'scoop uninstall $args[0]' 'Remove Scoop apps.'

# upgrade
scoop alias add upgrade 'scoop update *' 'Update all apps.'

# Delete the cache as well during cleanup.
scoop alias add prune 'scoop cleanup $args[0] --cache' 'Clean Scoop apps by removing old versions and caches.'

# Update all & show status
scoop alias add outdated 'scoop update; scoop status' 'Show all outdated Scoop apps.'
scoop alias add up 'scoop update; scoop status' 'Show all outdated Scoop apps.'

# reinstall
scoop alias add ri 'scoop uninstall $args[0]; scoop install $args[0]' 'Uninstall and then install app'
scoop alias add reinstall 'scoop uninstall $args[0]; scoop install $args[0]' 'Uninstall and then install app'

scoop alias add ls 'scoop list' 'Show installed apps list'

scoop alias add s 'scoop search $args[0]' 'Search Scoop apps'




# --------------------------------------------------------------------------------------------------
# Global initialization
# --------------------------------------------------------------------------------------------------
Write-Host "Next, install app by scoop..." -ForegroundColor Green
scoop install 7zip git --global

# --------------------------------------------------------------------------------------------------
# Add fetch destination
# --------------------------------------------------------------------------------------------------
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts # For Terminal(oh-my-posh design) font(https://github.com/matthewjberger/scoop-nerd-fonts)
scoop bucket add games


# --------------------------------------------------------------------------------------------------
# Unix like for Windows
# --------------------------------------------------------------------------------------------------
scoop install msys2 # windows in Unix shell: info JP(https://qiita.com/Ted-HM/items/4f2feb9fdacb6c72083c)
msys2 -mintty

scoop install make
scoop install cmake
scoop install psutils


# --------------------------------------------------------------------------------------------------
# Shell design
# --------------------------------------------------------------------------------------------------
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
scoop install CodeNewRoman-NF-Mono

# --------------------------------------------------------------------------------------------------
# Convenience
# --------------------------------------------------------------------------------------------------
scoop install hadolint # Docker linter
scoop install shfmt # Makefile formatter
scoop install pandoc # Markdown to PDF
scoop install resource-hacker # exe icon edit

scoop install bat # Syntax highlighting and Git integration(https://github.com/sharkdp/bat)
scoop install fzf # A command-line fuzzy finder(https://github.com/junegunn/fzf)

scoop install concfg # Import and export Windows console settings (https://github.com/lukesampson/concfg)
scoop install pshazz # Git and Mercurial tab completion, etc... (https://github.com/lukesampson/pshazz)


# --------------------------------------------------------------------------------------------------
# Editor
# --------------------------------------------------------------------------------------------------
scoop install vim
scoop install neovim


# --------------------------------------------------------------------------------------------------
# Languages
# --------------------------------------------------------------------------------------------------
scoop install python39
scoop install nodejs-lts # Nodejs Package Manager(e.g: nodejs-lts (16.13.0))
scoop install deno

Write-Host "Please include the following by yourself." -ForegroundColor Blue
Write-Host "  - global npm packages(Option)" -ForegroundColor Blue
Write-Host "      windows\setup\options\global-libs\nodejs.ps1 -Manager pnpm"
