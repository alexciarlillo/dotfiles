# Changelog

A running log of things I've updated or fixed. Newest first.

## 2026-05-12

- Replaced `difi.nvim` with `diffview.nvim` (`universal/.config/nvim/lua/plugins/diffview.lua`). Added `<leader>gd` / `<leader>gD` to toggle Diffview (current index vs HEAD, and `origin/HEAD...HEAD`) in `universal/.config/nvim/lua/plugins/snacks.lua`.
- Enabled the `lazyvim.plugins.extras.editor.snacks_picker` extra and switched `easy-dotnet.nvim`'s picker from `fzf` to `snacks`. The old `fzf.lua` plugin spec is parked as `fzf.lua.bak` in case I want to restore custom fzf-lua actions later.

## 2026-05-07

- Added `README.md` and this `CHANGELOG.md`.
- Claude hooks weren't actually firing — `~/.claude/settings.json` was missing the `hooks` block. Fixed on this machine; the block to merge lives in `universal/.claude/README.md`. The settings file is per-machine and not stowed, so it needs to be applied on each new setup.
- Tmux bell rendering now configured in `universal/.config/tmux/tmux.conf.user`: `monitor-bell on`, `bell-action other`, red `window-status-bell-style`. Claude's BEL writes now show up as a red window-status flag that clears on focus.
- Wired `tmux-clear-indicator.sh` into `twork-init` via `after-select-window` on `edit`, `agent`, and `adhoc`. The README claimed this was already done but it wasn't.
- Aligned Claude hook scripts (`notify-tmux.sh`, `tmux-clear-indicator.sh`) with the real session names (`edit agent adhoc`) — they were targeting a `runtime` session that doesn't exist.
