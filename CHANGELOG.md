# Changelog

A running log of things I've updated or fixed. Newest first.

## 2026-07-08

- Added Claude Code worktree hooks (`universal/.local/bin/_worktree-hook-create`, `_worktree-hook-remove`), wired via `WorktreeCreate`/`WorktreeRemove` in `settings.json`. Intentional feature worktrees in a bare-hub layout (root holding `.bare/` + sibling worktrees) route through `_worktree`/`_worktree-rm` so they get the sibling layout, tracking branch, and post-create hooks; throwaway subagent worktrees (`isolation: worktree`) and plain-clone repos fall through to a plain `git worktree add/remove`. It's a global hook, so the passthrough keeps it from breaking non-bare-hub repos.
- Checked in `universal/.claude/settings.json` (previously per-machine and unstowed). Includes `alwaysThinkingEnabled`, `effortLevel: high`, the `clangd-lsp` plugin, an agent-teams env flag, and all hook wiring. `bootstrap.sh`'s `universal_dots` now backs up a real (non-symlink) `~/.claude/settings.json` to `.bak` before stowing, since Claude writes that file on first run.
- Added TPM-based tmux plugin management. `bootstrap.sh` `tpm_init` clones TPM into `~/.config/tmux/plugins/` and installs plugins via a throwaway detached session; `tmux.conf.user` declares plugins through `@tpm_plugins` (not `set -g @plugin`, which TPM can't discover through the `if-shell` sourcing) and sets `TMUX_PLUGIN_MANAGER_PATH` explicitly. Added `hiroppy/tmux-agent-sidebar`; Claude hooks now drive it (session-start/stop/notification/user-prompt-submit) alongside the existing `notify-tmux.sh` window-name notifier. `plugins/` is gitignored.
- Removed the `bind e` edit-config binding from `.tmux.conf`.
- Dropped `RBLX_USER` branch-prefix logic from `_worktree`.

## 2026-07-07

- Overhauled `clean-merged-wt` (`git clean-wt`): colorized output and safer detection of "done" worktrees (branch merged into origin's primary branch, or gone upstream).

## 2026-07-06

- Moved named directory hashes (`~vault`, `~agent`) into `universal/.config/zsh/env.d/named-dirs.zsh` so they resolve in non-interactive shells (sourced from `.zshenv`), not just interactive ones.

## 2026-07-01

- Added `neru` config (`universal/.config/neru/config.toml`) — a macOS modal keyboard-navigation overlay (light/dark palette, zsh exec shell). Introduced 06-30, tuned 07-01.
- Skill doc updates (`voice-server-docs`, `handoff`).

## 2026-06-10

- Switched the `clone-wt` / `clean-wt` git aliases to invoke their scripts with `bash` instead of `sh` (both use bash-only features under `set -euo pipefail`).

## 2026-06-09

- Split shell config into `.zshenv` (exports for all shells) and `.zshrc` (interactive only). Non-interactive shells (scripts, Claude Code, cron) now see `PATH`, `AGENT_HANDOFF_DIR`, `RBLX_USER`, etc.
- Introduced drop-in directories `~/.config/zsh/env.d/` and `~/.config/zsh/interactive.d/` for modular private configs. Files matching `*.zsh` are sourced automatically.
- Decomposed the monolithic `~/.config/zsh/rbx` into `env.d/rbx.zsh` (exports) and `interactive.d/rbx.zsh` (functions, completions). Prepares for eventual extraction to a private repo.
- Deduplicated the `.dotnet/tools` PATH export (was in both `.zshrc` and `rbx`; now only in `.zshenv`).
- Moved work-specific shell configs into a separate `rblx/` stow package. Bootstrap conditionally stows it if the directory exists, so the repo works without it (for eventual private repo split).
- Deleted the retired Linux desktop configs (i3, polybar, compton, dunst, kitty, feh wallpapers, `user-dirs.dirs`); `linux/` now carries only its `.stow-local-ignore`.
- Hardened `cargo_init`: skips cleanly when `extra/cargo/packages.txt` has no non-blank lines (avoids `cargo install` with zero args under `set -e`) and feeds crates on stdin, since BSD/macOS `xargs` has no GNU `-a/--arg-file` flag.
- `.zshenv` now sources `$CARGO_HOME/env` only if the file exists, so a machine with `~/.cargo` but no rustup env file doesn't error on shell startup.
- All `stow` calls use `--no-folding` so each file is symlinked individually (no whole-directory symlinks that would trap app-written files).
- Added `rblx_init` to bootstrap (sources `extra/rblx/setup.sh` when present) and reordered `main()` so init steps are skipped in `dots` mode; the Linux path now also runs `linux_dots`.
- Checked in the Roblox C++ style guide and Voice SFU rules plus a `voice-server-cpp-reviewer` agent under `rblx/.claude/`.

## 2026-06-05

- Added a worktree post-create hook (`universal/.config/worktree/hooks.d/post-create.d/30-game-engine`) that bootstraps game engine worktrees with a local `.clangd` config.
- Unignored `universal/.claude/` and checked in hook scripts (`notify-tmux.sh`, `tmux-clear-indicator.sh`), rules, and a handoff skill.
- Fixed clangd LSP config in Neovim — corrected `compilationDatabasePath` and query driver settings.
- Removed the Obsidian plugin (`lua/plugins/obsidian.lua`); added clangd language server setup to `lsp.lua`.
- Removed `yazi` from `extra/cargo/packages.txt`.
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
