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


# ------------------------------------------------------------------------------
# docker-compose commands
# ------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
	SHELL := pwsh
else
	SHELL := bash
endif

CORE_SERVICES := "app"
ALL_SERVICES := ${CORE_SERVICES}

CORE_SERVICES_FILES := -f docker-compose.yml
COMPOSE_ALL_FILES := ${CORE_SERVICES_FILES}
CORE_SERVICES_FILES := -f docker-compose.yml

dc-all: down core

dc-build:
	@docker-compose ${COMPOSE_ALL_FILES} up -d --build ${ALL_SERVICES}

dc-core:
	@docker-compose ${COMPOSE_CORE_FILES} up -d --build ${CORE_SERVICES}

dc-down:
	@docker-compose ${COMPOSE_ALL_FILES} down

dc-stop:
	@docker-compose ${COMPOSE_ALL_FILES} stop ${ALL_SERVICES}

dc-restart:
	@docker-compose ${COMPOSE_ALL_FILES} restart ${ALL_SERVICES}

dc-rm:
	@docker-compose $(COMPOSE_ALL_FILES) rm -f ${ALL_SERVICES}

dc-logs:
	@docker-compose $(COMPOSE_ALL_FILES) logs --follow --tail=1000 ${ALL_SERVICES}

dc-images:
	@docker-compose $(COMPOSE_ALL_FILES) images ${ALL_SERVICES}

dc-clean: ## Remove all Containers and Delete Volume Data
	@docker-compose ${COMPOSE_ALL_FILES} down -v


.PHONY: clean test
