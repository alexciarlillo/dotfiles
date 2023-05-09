DOTFILES="${HOME}/.dotfiles"


osx: universal-dots osx-dots

osx-dots:
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" osx

linux: universal-dots linux-dots

linux-dots:
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" linux

universal-dots:
	stow --restow --ignore ".DS_Store" --target="$(HOME)" --dir="$(DOTFILES)" universal

homebrew:
	brew bundle --file="$(DOTFILES)/extra/homebrew/Brewfile"
	brew cleanup
	brew doctor

.PHONY: osx linux universal homebrew
