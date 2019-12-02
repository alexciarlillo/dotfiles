DOTFILES="${HOME}/.dotfiles"
SCRIPTS="${DOTFILES}/scripts"


osx: universal homebrew
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" osx

linux: universal
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" linux

universal:
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" universal

homebrew:
	brew bundle --file="$(DOTFILES)/extra/homebrew/Brewfile"
	brew cleanup
	brew doctor

.PHONY: osx linux universal homebrew
