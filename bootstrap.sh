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

cargo_init() {
  if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  fi
  xargs -a "$DOTFILES/extra/cargo/packages.txt" cargo install
}

hammerspoon_spoons() {
  local spoons_dir="$DOTFILES/osx/.hammerspoon/Spoons"
  local urls_file="$DOTFILES/extra/hammerspoon/spoon-zip-urls"
  [[ ! -f "$urls_file" ]] && return 0
  mkdir -p "$spoons_dir"
  while IFS= read -r url; do
    [[ -z "$url" ]] && continue
    local filename spoon_name
    filename="$(basename "$url")"
    spoon_name="${filename%.zip}"
    [[ -d "$spoons_dir/$spoon_name" ]] && continue
    curl -sSL -o "$spoons_dir/$filename" "$url"
    unzip -qo "$spoons_dir/$filename" -d "$spoons_dir/"
    rm "$spoons_dir/$filename"
  done <"$urls_file"
}

setup_zsh_from_bash() {
  if command -v zsh &>/dev/null && [[ -f ~/.bashrc ]]; then
    if ! grep -q "exec /bin/zsh" ~/.bashrc; then
      printf '\nexport SHELL=/bin/zsh\nexec /bin/zsh -l\n' >>~/.bashrc
    fi
  fi
}

universal_dots() {
  if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
    mv ~/.zshrc ~/.zshrc.bak
  fi

  # If .gitconfig exists and isn't already our symlink, preserve it as .gitconfig.local
  if [[ -f ~/.gitconfig && ! -L ~/.gitconfig ]]; then
    if [[ ! -f ~/.gitconfig.local ]]; then
      mv ~/.gitconfig ~/.gitconfig.local
    else
      rm ~/.gitconfig
    fi
  fi

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
    [[ "${1:-}" != "dots" ]] && cargo_init
    universal_dots
    hammerspoon_spoons
    osx_dots
    ;;
  Linux)
    [[ "${1:-}" != "dots" ]] && linux_init
    [[ "${1:-}" != "dots" ]] && cargo_init
    setup_zsh_from_bash
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
