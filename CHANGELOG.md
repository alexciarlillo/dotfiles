# Changelog

A running log of things I've updated or fixed. Newest first.

## 2026-06-05

- Removed the `Makefile` — all functionality consolidated into `bootstrap.sh` as the single entry point.
- Added cargo package management: `extra/cargo/packages.txt` lists crates to install; `bootstrap.sh` installs rustup if needed and runs `cargo install` for each.
- Moved Hammerspoon spoon downloads from the Makefile into `bootstrap.sh`.
- Formalized `.gitconfig.local` pattern: `[user]` block removed from the stowed `.gitconfig`; bootstrap now migrates an existing non-symlinked `.gitconfig` into `.gitconfig.local` to preserve per-machine identity and credentials.
- Added `[url "https://"] insteadOf = git://` to `.gitconfig` for environments that block the git protocol.
- Made pyenv initialization in `.zshrc` conditional on `~/.pyenv` existing.
- Added `setup_zsh_from_bash` to bootstrap: appends `exec /bin/zsh -l` to `.bashrc` on Linux if zsh is installed.
- Agent handoff directory (`$HOME/agents/handoffs`) is now created automatically in `.zshrc` if missing.
- Added Edit/Write permissions for `CHANGELOG.md` and `README.md` in `.claude/settings.local.json` so the pre-commit hook agent can update them.

## 2026-05-12

- Replaced `difi.nvim` with `diffview.nvim` (`universal/.config/nvim/lua/plugins/diffview.lua`). Added `<leader>gd` / `<leader>gD` to toggle Diffview (current index vs HEAD, and `origin/HEAD...HEAD`) in `universal/.config/nvim/lua/plugins/snacks.lua`.
- Enabled the `lazyvim.plugins.extras.editor.snacks_picker` extra and switched `easy-dotnet.nvim`'s picker from `fzf` to `snacks`. The old `fzf.lua` plugin spec is parked as `fzf.lua.bak` in case I want to restore custom fzf-lua actions later.

## 2026-05-07

- Added `README.md` and this `CHANGELOG.md`.
- Claude hooks weren't actually firing — `~/.claude/settings.json` was missing the `hooks` block. Fixed on this machine; the block to merge lives in `universal/.claude/README.md`. The settings file is per-machine and not stowed, so it needs to be applied on each new setup.
- Tmux bell rendering now configured in `universal/.config/tmux/tmux.conf.user`: `monitor-bell on`, `bell-action other`, red `window-status-bell-style`. Claude's BEL writes now show up as a red window-status flag that clears on focus.
- Wired `tmux-clear-indicator.sh` into `twork-init` via `after-select-window` on `edit`, `agent`, and `adhoc`. The README claimed this was already done but it wasn't.
- Aligned Claude hook scripts (`notify-tmux.sh`, `tmux-clear-indicator.sh`) with the real session names (`edit agent adhoc`) — they were targeting a `runtime` session that doesn't exist.
