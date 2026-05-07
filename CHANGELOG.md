# Changelog

A running log of things I've updated or fixed. Newest first.

## 2026-05-07

- Added `README.md` and this `CHANGELOG.md`.
- Claude hooks weren't actually firing — `~/.claude/settings.json` was missing the `hooks` block. Fixed on this machine; the block to merge lives in `universal/.claude/README.md`. The settings file is per-machine and not stowed, so it needs to be applied on each new setup.
- Tmux bell rendering now configured in `universal/.config/tmux/tmux.conf.user`: `monitor-bell on`, `bell-action other`, red `window-status-bell-style`. Claude's BEL writes now show up as a red window-status flag that clears on focus.
- Wired `tmux-clear-indicator.sh` into `twork-init` via `after-select-window` on `edit`, `agent`, and `adhoc`. The README claimed this was already done but it wasn't.
- Aligned Claude hook scripts (`notify-tmux.sh`, `tmux-clear-indicator.sh`) with the real session names (`edit agent adhoc`) — they were targeting a `runtime` session that doesn't exist.
