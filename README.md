# dotfiles

Personal cross-platform dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and a `Makefile`. Primary target is macOS; Linux is kept working for occasional use.

This README is the cheat sheet for what to do when I sit down at a new (or another) machine.

---

## TL;DR — common scenarios

### Brand new machine

```bash
git clone git@github.com:alexciarlillo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make init            # brew bundle (macOS) or apt install (Linux)
make osx             # or: make linux
```

On macOS, `make osx` also downloads Hammerspoon Spoons listed in `extra/hammerspoon/spoon-zip-urls`.

Per-machine Claude setup: merge the `hooks` block from [`universal/.claude/README.md`](universal/.claude/README.md) into `~/.claude/settings.json` (that file is intentionally not stowed).

### Pulling latest changes on an existing machine

```bash
cd ~/.dotfiles
git pull
make osx             # or: make linux
```

`make osx` / `make linux` re-run `stow --restow` — safe to run repeatedly, just refreshes symlinks. If I added new Brew/apt packages, also `make init`.

### Changing a config and sharing it

1. Edit the file **inside** `~/.dotfiles/` (not the symlink target in `~`). Most `~/.foo` files are already symlinks pointing into this repo, so editing `~/.zshrc` edits `universal/.zshrc`. That's fine.
2. Commit and push:
   ```bash
   cd ~/.dotfiles && git add -A && git commit -m "describe the change" && git push
   ```
3. On the other machine: `git pull && make osx` (or `make linux`).
4. Note what changed in [`CHANGELOG.md`](CHANGELOG.md).

---

## Layout

```
dotfiles/
  universal/   Cross-platform configs — stowed into ~
  osx/         macOS-only (AeroSpace, Hammerspoon, Sublime) — stowed into ~
  linux/       Linux-only (i3, polybar, compton, kitty) — stowed into ~
  extra/       NOT stowed — used by Makefile targets
    homebrew/  Brewfile
    apt/       packages.txt
    hammerspoon/ spoon-zip-urls (fetched during `make osx`)
```

The directory layout inside `universal/` / `osx/` / `linux/` mirrors `$HOME`. So `universal/.config/nvim/init.lua` ends up at `~/.config/nvim/init.lua`.

Per-package `.stow-local-ignore` files keep things like `.DS_Store` and `.local/` out of the symlink pass.

---

## What's in here

### Shell & terminal

- **Zsh** (`universal/.zshrc`, `universal/.config/zsh/`) — aliases, `twork-*` tmux helpers, Vault helpers, worktree helpers
- **WezTerm** (`universal/.wezterm.lua`) — primary terminal
- **Tmux** (`universal/.tmux.conf`, `universal/.config/tmux/tmux.conf.user`) — prefix `C-Space`, vim-style pane nav, bell-based notifications

### Editor

- **Neovim** (`universal/.config/nvim/`) — LazyVim base with custom plugin configs in `lua/plugins/` and overrides in `lua/config/`
- **Vim** (`universal/.vimrc`) — minimal fallback

### Git & CLI

- **Git** (`universal/.gitconfig`, `universal/.gitignore_global`)
- **Ripgrep** (`universal/.ripgreprc`)
- **Lazygit** (`universal/.config/lazygit/`)

### macOS window management

- **AeroSpace** (`osx/.aerospace.toml`) — tiling WM with workspace keybindings
- **Hammerspoon** (`osx/.hammerspoon/`) — window manipulation and automation. Spoons are fetched by the Makefile

### Linux desktop

- **i3**, **polybar**, **compton**, **dunst**, **kitty**, **feh** — under `linux/.config/`

### Claude Code

`universal/.claude/` — hook scripts that surface Claude state in the tmux window name and ring the terminal bell. See [`universal/.claude/README.md`](universal/.claude/README.md). `~/.claude/settings.json` is per-machine and not stowed.

---

## Tmux workflow (`twork-*`)

Paired tmux sessions (`edit`, `agent`, `adhoc`) keyed by window name, defined in `universal/.config/zsh/tmux`:

| Function                                     | What it does                                                  |
| -------------------------------------------- | ------------------------------------------------------------- |
| `twork-init`                                 | Creates all three sessions, wires `after-select-window` hooks |
| `twork-new [name] <path>`                    | Opens a paired window across all three sessions               |
| `twork-close [name]`                         | Kills the paired windows                                      |
| `twork-edit` / `twork-agent` / `twork-adhoc` | Attach to the named session                                   |
| `twork-sync`                                 | Sync current pane's cwd to paired windows                     |
| `twork-ls`                                   | List active projects                                          |

Claude hooks (`universal/.claude/hooks/notify-tmux.sh`) annotate window names with `⠋` (working) or `?` (needs input) across all three sessions, plus a red bell flag that clears on focus.

---

## Adding things

### A new dotfile

1. Drop it into `universal/` (or `osx/` / `linux/`) at the path it should have under `$HOME`. E.g. `~/.config/foo/bar.toml` → `universal/.config/foo/bar.toml`.
2. `make osx` (or `make linux`) — Stow creates the symlink.
3. Commit and push.

If an app rewrites its config on launch (clobbers symlinks), put the source of truth in `extra/` and add a copy step to the Makefile instead of stowing it.

### A new package

- **macOS**: edit `extra/homebrew/Brewfile`, then `make init` (or `brew bundle --file=extra/homebrew/Brewfile`).
- **Linux**: edit `extra/apt/packages.txt`, then `make init`.

### Unstowing a removed file

Stow doesn't automatically clean up symlinks for files you deleted from the repo. Unstow manually:

```bash
stow --delete --target="$HOME" --dir="$PWD" universal
```

---

## Conventions

- Cross-platform stuff → `universal/`. Platform-specific (WM, GUI app, hardware) → `osx/` or `linux/`.
- Per-machine state (`~/.claude/settings.json`, shell history, secrets) stays out of the repo.
- Changes are tracked in [`CHANGELOG.md`](CHANGELOG.md) — just a running log, not formal releases.

---

## Quick reference

| I want to...                  | Run                                                     |
| ----------------------------- | ------------------------------------------------------- |
| Set up a brand new machine    | `make init && make osx`                                 |
| Pull latest changes           | `git pull && make osx`                                  |
| Re-link configs after editing | `make osx`                                              |
| Install newly-added packages  | `make init`                                             |
| Unstow a removed file         | `stow --delete --target="$HOME" --dir="$PWD" universal` |

---
