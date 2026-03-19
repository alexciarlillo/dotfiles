DOTFILES := $(CURDIR)
SPOONS_DIR := osx/.hammerspoon/Spoons
UNAME := $(shell uname -s)

.PHONY: init osx linux universal homebrew apt-packages hammerspoon-pre-dots

ifeq ($(UNAME),Darwin)
init: homebrew
else ifeq ($(UNAME),Linux)
init: apt-packages
else
init:
	@echo "Unsupported OS: $(UNAME)"
	@exit 1
endif

osx: universal-dots hammerspoon-pre-dots osx-dots

osx-dots:
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" osx

linux: universal-dots linux-dots

linux-dots:
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" linux

universal-dots:
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" universal

hammerspoon-pre-dots:
	for url in $(shell cat extra/hammerspoon/spoon-zip-urls); do \
		curl -sSL -o $(SPOONS_DIR)/$$(basename $$url) $$url && \
		unzip -qo $(SPOONS_DIR)/$$(basename $$url) -d $(SPOONS_DIR)/ && \
		rm $(SPOONS_DIR)/$$(basename $$url); \
	done

homebrew:
	brew bundle --file="$(DOTFILES)/extra/homebrew/Brewfile"
	brew cleanup
	brew doctor

apt-packages:
	@if [ -f "$(DOTFILES)/extra/apt/packages.txt" ]; then \
		xargs -a "$(DOTFILES)/extra/apt/packages.txt" sudo apt-get install -y; \
	else \
		echo "No apt packages file found at extra/apt/packages.txt"; \
	fi
