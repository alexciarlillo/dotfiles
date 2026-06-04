#!/usr/bin/env bash

# On coder devspaces, dotfiles is cloned to /home/coder/.config/coderv2/dotfiles
# output of execution is at ~/.dotfiles.log
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

osx_init() {
  brew bundle --file="$DOTFILES/extra/homebrew/Brewfile"
  brew cleanup
  set +e
  brew doctor
  set -e
}

linux_init() {
  sudo apt-get update
  xargs -a "$DOTFILES/extra/apt/packages.txt" sudo apt-get install -y
}

universal_dots() {
  mv ~/.zshrc ~/.zshrc.bak 2>/dev/null || true
  stow --restow --ignore ".DS_Store" --target="$HOME" --dir="$DOTFILES" universal
}

osx_dots() {
  stow --restow --ignore ".DS_Store" --target="$HOME" --dir="$DOTFILES" osx
}

linux_dots() {
  stow --restow --ignore ".DS_Store" --target="$HOME" --dir="$DOTFILES" linux
}

main() {
  local uname_s
  uname_s="$(uname -s)"
  case "$uname_s" in
  Darwin)
    [[ "${1:-}" != "dots" ]] && osx_init
    universal_dots
    osx_dots
    ;;
  Linux)
    [[ "${1:-}" != "dots" ]] && linux_init
    universal_dots
    ;;
  *)
    echo "Unsupported OS: $uname_s" >&2
    exit 1
    ;;
  esac
  echo ""
  echo "Bootstrap complete for $uname_s"
}

main "$@"
