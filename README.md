# dotfiles

Personal cross-platform dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and a `bootstrap.sh` script. Primary target is macOS; Linux/devspaces supported via the same script. Compatible with [Coder devspaces dotfiles](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account#dotfiles).

This README is the cheat sheet for what to do when I sit down at a new (or another) machine.

---

## TL;DR — common scenarios

### Brand new machine

```bash
git clone git@github.com:alexciarlillo/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh       # installs packages + stows configs (detects macOS/Linux)
```

Claude Code config (`~/.claude/settings.json`, hooks, rules) is now stowed from `universal/.claude/`. Claude writes `settings.json` itself on first run, so if a real (non-symlink) copy already exists, `bootstrap.sh` moves it to `settings.json.bak` before linking ours. Machine-local overrides go in the unstowed `~/.claude/settings.local.json`.

### Coder devspaces

Point your devspace dotfiles setting at this repo. Coder clones it to `/home/coder/.config/coderv2/dotfiles` and runs `bootstrap.sh` automatically. It backs up the existing `~/.zshrc` to `~/.zshrc.bak` before stowing.

### Pulling latest changes on an existing machine

```bash
cd ~/.dotfiles
git pull
./bootstrap.sh       # re-stows configs + installs any new packages
```

To re-link configs without reinstalling packages:

```bash
./bootstrap.sh dots
```

### Changing a config and sharing it

1. Edit the file **inside** `~/.dotfiles/` (not the symlink target in `~`). Most `~/.foo` files are already symlinks pointing into this repo, so editing `~/.zshrc` edits `universal/.zshrc`. That's fine.
2. Commit and push:
   ```bash
   cd ~/.dotfiles && git add -A && git commit -m "describe the change" && git push
   ```
3. On the other machine: `git pull && ./bootstrap.sh`
4. Note what changed in [`CHANGELOG.md`](CHANGELOG.md).

---

## Layout

```
dotfiles/
  bootstrap.sh  Entry point — detects OS, installs packages, stows configs
  universal/    Cross-platform configs — stowed into ~
  rblx/         Work-specific configs — stowed into ~ (lifts out for private repo)
  osx/          macOS-only (AeroSpace, Hammerspoon) — stowed into ~
  linux/        Linux-only (currently just a .stow-local-ignore) — stowed into ~
  vault/        Obsidian vault .claude/ (slash commands) — stowed into ~/vault (guarded)
  extra/        NOT stowed — used by bootstrap.sh
    homebrew/   Brewfile
    apt/        packages.txt
    cargo/      packages.txt
    hammerspoon/  spoon zip URLs
    rblx/       optional work-machine setup hook (setup.sh)
```

The directory layout inside `universal/` / `osx/` / `linux/` mirrors `$HOME`. So `universal/.config/nvim/init.lua` ends up at `~/.config/nvim/init.lua`.

Per-package `.stow-local-ignore` files keep things like `.DS_Store` and `.local/` out of the symlink pass.

---

## What's in here

### Shell & terminal

- **Zsh** — two-file setup:
  - `universal/.zshenv` — exports visible to all shells (PATH, NVM, pyenv, agent dirs). Sources `~/.config/zsh/env.d/*.zsh` for private exports.
  - `universal/.zshrc` — interactive-only (plugins, aliases, starship). Sources `~/.config/zsh/interactive.d/*.zsh` for private functions.
  - `universal/.config/zsh/` — aliases, git helpers, tmux helpers (public); `env.d/` and `interactive.d/` for drop-in private configs.
- **WezTerm** (`universal/.wezterm.lua`) — primary terminal
- **Tmux** (`universal/.tmux.conf`, `universal/.config/tmux/tmux.conf.user`) — prefix `C-Space`, vim-style pane nav, bell-based notifications. Plugins are managed with [TPM](https://github.com/tmux-plugins/tpm) (bootstrapped by `bootstrap.sh`, installed under `~/.config/tmux/plugins/`, gitignored); declared via `@tpm_plugins`. Includes `hiroppy/tmux-agent-sidebar`.

### Editor

- **Neovim** (`universal/.config/nvim/`) — LazyVim base with custom plugin configs in `lua/plugins/` and overrides in `lua/config/`
- **Vim** (`universal/.vimrc`) — minimal fallback

### Git & CLI

- **Git** (`universal/.gitconfig`, `universal/.gitignore_global`)
- **Ripgrep** (`universal/.ripgreprc`)
- **Lazygit** (`universal/.config/lazygit/`)

### macOS window management

- **AeroSpace** (`osx/.aerospace.toml`) — tiling WM with workspace keybindings
- **Hammerspoon** (`osx/.hammerspoon/`) — window manipulation and automation
- **neru** (`universal/.config/neru/config.toml`) — modal keyboard-navigation overlay

### Linux desktop

The old i3/polybar/compton/dunst desktop configs were retired; `linux/` currently holds only its `.stow-local-ignore`. Linux/devspace use now leans on the shared `universal/` shell + terminal configs.

### Claude Code

`universal/.claude/` is stowed into `~/.claude/`:

- `settings.json` — thinking/effort defaults, plugins, and hook wiring (see the note in [Brand new machine](#brand-new-machine); machine-local overrides go in the unstowed `settings.local.json`).
- `hooks/` — `notify-tmux.sh` surfaces Claude state in the tmux window name and rings the terminal bell.
- `rules/`, `skills/` — shared agent rules and skills.

Worktree hooks (`universal/.local/bin/_worktree-hook-{create,remove}`) are wired via `WorktreeCreate`/`WorktreeRemove` so Claude's worktrees follow my bare-hub layout. See [`universal/.claude/README.md`](universal/.claude/README.md).

---

## Agent workspace ↔ Obsidian vault

The `~/agents` work-management workspace (`research`, `plans`, `handoffs`, `reviews`, `archives`, `prompts`) is surfaced **inside** the Obsidian vault so it's indexed, linkable, and portable to the phone — while `~/agents` stays the real `$AGENT_WORK_DIR` that agent tooling resolves. The setup spans several touchpoints:

- **Canonical bytes live in the vault** at `~/vault/10 - Agents/<Context>/<Kind>/`. Each `~/agents/<kind>` is a **symlink** into that subtree, so `$AGENT_WORK_DIR/<kind>` resolves normally.
- **Obsidian Sync** carries the vault (including `10 - Agents/`) to other Obsidian devices and the phone.
- **Unison** (`osx/.unison/agents.prf`) syncs `~/agents` to the sandboxed remote (`coder-engine:/home/coder/agents`), which has **no** vault. The profile `follow`s the per-kind symlinks so their contents land as **real dirs** on the remote. It ignores `review-queue.base` (an Obsidian Base view) and `.obsidian` (per-machine config), and runs every 300s via the `com.aciarlillo.agent-sync` LaunchAgent (`extra/launchd/`, wrapper `~/.local/bin/agent-sync`).

```
VAULT  (Obsidian Sync → phone + every vault-present desktop)
~/vault/10 - Agents/
├─ Work/
│  ├─ Research/   [REAL] ═ canonical bytes
│  ├─ Plans/      [REAL]
│  ├─ Handoffs/   [REAL]
│  ├─ Reviews/    [REAL]
│  ├─ Archives/   [REAL]
│  ├─ Prompts/    [REAL]
│  └─ review-queue.base   [REAL, Obsidian Base]
└─ Personal/
   ├─ Research/   [REAL]   (…same six kinds + review-queue.base)
   └─ …

MAC  (context = Work)                                  REMOTE  (context = Work; NO vault)
~/agents/                                              ~/agents/  (= /home/coder/agents)
├─ research  ····► ~/vault/10 - Agents/Work/Research   ├─ research/   [REAL]  ← Unison follow
├─ plans     ····► …/Work/Plans                        ├─ plans/      [REAL]
├─ handoffs  ····► …/Work/Handoffs                     ├─ handoffs/   [REAL]
├─ reviews   ····► …/Work/Reviews                      ├─ reviews/    [REAL]
├─ archives  ····► …/Work/Archives                     ├─ archives/   [REAL]
├─ prompts   ····► …/Work/Prompts                      ├─ prompts/    [REAL]
└─ artifacts/  [REAL, local; never in vault]           └─ artifacts/  [REAL]

  ····► = symlink (pointer, no bytes)      [REAL] = actual bytes on disk

SYNC PATHS
  research / plans / handoffs / reviews / archives / prompts : phone ◄─Obsidian─► MAC(vault) ◄─Unison follow─► REMOTE
  artifacts                                                  : (never on phone) ;  MAC ◄─Unison─► REMOTE
```

### Context (Work vs Personal)

`agents_workspace_links()` in `bootstrap.sh` picks which vault subtree to link into, derived from this clone's `origin` remote: `github.rbx.com` → `Work`, `github.com` → `Personal`. Override with `AGENT_CONTEXT=Work|Personal`. It guards on `~/vault` existing, so vault-less machines (the remote) skip linking and keep real dirs for Unison. It refuses to clobber a `~/agents/<kind>` that's still a real dir — that migration is deliberate (below).

**Why `vault/` is its own stow package (not under `universal/`):** `universal/` is stowed unconditionally to `$HOME`, but `~/vault` only exists on Obsidian machines. Keeping `vault_dots` guarded on `~/vault` avoids creating a stray `~/vault` on servers — which would also defeat the `[[ -d "$HOME/vault" ]]` guard `agents_workspace_links` relies on. (`agents/` *is* under `universal/` because `~/agents` exists on every machine, including the remote.)

### Migrating a machine into the vault layout

On a vault machine whose `~/agents/<kind>` are still real dirs, do a one-time cutover. **Order matters** so the 300s Unison timer never mass-deletes the remote:

1. The profile is already armed (`follow = Path <kind>` per kind) — a no-op while the paths are real dirs, but it makes any sync during/after the move follow the symlinks instead of propagating deletions.
2. Pause the timer: `launchctl bootout gui/$(id -u)/com.aciarlillo.agent-sync`.
3. Per kind: move `~/agents/<kind>/*` into `~/vault/10 - Agents/<Context>/<Kind>/`, then remove the now-empty `~/agents/<kind>`. Move `~/agents/review-queue.base` into `~/vault/10 - Agents/<Context>/`.
4. `./bootstrap.sh dots` — `agents_workspace_links` creates the symlinks.
5. `unison agents` — confirm it reconciles with **no deletions** (a clean cutover shows "nothing to do").
6. Resume: `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.aciarlillo.agent-sync.plist`.

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
2. `./bootstrap.sh dots` — Stow creates the symlink.
3. Commit and push.

If an app rewrites its config on launch (clobbers symlinks), put the source of truth in `extra/` and add a copy step to `bootstrap.sh` instead of stowing it.

### A new package

- **macOS**: edit `extra/homebrew/Brewfile`, then `./bootstrap.sh`.
- **Linux**: edit `extra/apt/packages.txt`, then `./bootstrap.sh`.
- **Cargo (both)**: edit `extra/cargo/packages.txt`, then `./bootstrap.sh`.

### Unstowing a removed file

Stow doesn't automatically clean up symlinks for files you deleted from the repo. Unstow manually:

```bash
stow --delete --target="$HOME" --dir="$PWD" universal
```

---

## Conventions

- Cross-platform stuff → `universal/`. Platform-specific (WM, GUI app, hardware) → `osx/` or `linux/`.
- Per-machine state (`~/.claude/settings.local.json`, shell history, secrets, `.gitconfig.local`) stays out of the repo.
- Changes are tracked in [`CHANGELOG.md`](CHANGELOG.md) — just a running log, not formal releases.

---

## Quick reference

| I want to...                  | Run                                                     |
| ----------------------------- | ------------------------------------------------------- |
| Set up a brand new machine    | `./bootstrap.sh`                                        |
| Pull latest changes           | `git pull && ./bootstrap.sh`                            |
| Re-link configs after editing | `./bootstrap.sh dots`                                   |
| Unstow a removed file         | `stow --delete --target="$HOME" --dir="$PWD" universal` |

---
