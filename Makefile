linux:
		export USERNAME=`cmd.exe /c echo %username%`
		cd /mnt/c/Users/${USERNAME}/dotfiles
		bash "./install-wsl.sh"

linux-light:
		export USERNAME=`cmd.exe /c echo %username%`
		cd /mnt/c/Users/${USERNAME}/dotfiles
		bash "./install-wsl-light.sh" --light --zsh

wsl:
		powershell -c "git clone https://github.com/SARDONYX-sard/dotfiles.git $HOME/dotfiles"
		export USERNAME=`cmd.exe /c echo %username%`
		cd /mnt/c/Users/${USERNAME}/dotfiles
		bash "install-wsl.sh"


wsl-light:
		export USERNAME=`cmd.exe /c echo %username%`
		cd /mnt/c/Users/${USERNAME}/dotfiles
		bash "install-wsl.sh" --light --zsh

.PHONY: clean test
