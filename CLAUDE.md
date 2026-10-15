# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a personal dotfiles repository using GNU Stow for symlink management. The architecture is organized into platform-specific and universal configurations:

- `universal/` - Cross-platform configuration files (shell, git, editors, terminal, Claude Code)
- `rblx/` - Work-specific configs, stowed only when the directory exists (kept separable for eventual private-repo extraction)
- `personal/` - Personal-only overlay that exists only in the public repo (never in canonical). `bootstrap.sh`'s `OVERLAYS=(rblx personal)` drives `overlay_dots`/`overlay_init`, each guarded on the dir existing; `backport-public` strips `rblx` from the snapshot and `--exclude`s `personal`/`extra/personal` so its `rsync --delete` leaves them alone. Document personal-only config in `personal/README.md`, since this file is overwritten by backports.
- `osx/` - macOS-specific configurations (AeroSpace, Hammerspoon, neru)
- `linux/` - Linux-specific configs; the desktop configs (i3/polybar/compton/dunst) have been retired, so this currently holds only a `.stow-local-ignore`
- `extra/` - NOT stowed; resources consumed by `bootstrap.sh` (`homebrew/Brewfile`, `apt/packages.txt`, `cargo/packages.txt`, `hammerspoon/` spoon URLs, `launchd/` LaunchAgent plist templates instantiated into `~/Library/LaunchAgents`, optional `rblx/setup.sh`)

## Setup Commands

Full bootstrap (installs packages + stows configs):
```bash
./bootstrap.sh
```

Re-link configs only (skip package installation):
```bash
./bootstrap.sh dots
```

The bootstrap script detects the OS and:
- Installs platform packages (Homebrew on macOS, apt on Linux)
- Installs cargo packages from `extra/cargo/packages.txt` (installing rustup first if needed)
- Downloads Hammerspoon spoons and bootstraps TPM + tmux plugins
- Stows universal and platform-specific configs via GNU Stow (with `--no-folding`)

In `dots` mode only the stow steps run; package installation and other init steps are skipped.

## Key Configuration Structure

### Terminal & Shell Setup
- **WezTerm**: `universal/.wezterm.lua` - Modern terminal with custom keybindings
- **Zsh**: two-file split — `universal/.zshenv` (exports for all shells, incl. non-interactive) and `universal/.zshrc` (interactive only). Both source drop-in dirs (`~/.config/zsh/env.d/*.zsh`, `~/.config/zsh/interactive.d/*.zsh`) for private/modular config; public helpers/aliases live under `universal/.config/zsh/`.
- **Tmux**: `universal/.tmux.conf` (entry point) and `universal/.config/tmux/tmux.conf.user`. Plugins are managed via TPM under `~/.config/tmux/plugins/` (gitignored), declared with `@tpm_plugins`.
- **Per-host identity chip**: `universal/.config/remotes.conf` is a single pipe-delimited mapping (`id | match | display | fg | bg`) of hosts to colors. `universal/.local/bin/remote-badge` (POSIX sh, no deps — chosen over YAML so tmux/starship/zsh can all parse it without `yq`) resolves the current machine's row — an exported `REMOTE_ID` wins, else the first `match` glob that hits `hostname -f` — and emits a colored chip: `remote-badge starship` (raw truecolor ANSI, which starship passes through from a `[custom.remote]` module), `remote-badge tmux` (`#[...]` directives in `status-left`), or `remote-badge env` (exports `REMOTE_*`, eval'd by `interactive.d/remote-badge.zsh`). Deliberately **only the prompt hostname and tmux status bar are colored — never the terminal background** (the earlier OSC-11/12 `ssh-tint.zsh` approach, removed here, broke colorscheme readability). Starship's built-in `[hostname]` is disabled since the chip replaces it (with a plain-hostname fallback for unmapped SSH hosts). `match` is compared against each box's own `hostname -f`, not the ssh alias, so its globs must be verified per-machine and must not match the local mac (whose hostname is `HQ-*`); `REMOTE_ID` from an unstowed `env.d/` drop-in is the reliable per-box override.

### Editor Configuration  
- **Neovim**: Complete LazyVim setup in `universal/.config/nvim/`
  - Main config: `init.lua`
  - Plugin configs: `lua/plugins/` directory
  - Custom keymaps, options, and autocommands in `lua/config/`
- **Vim**: Basic configuration in `universal/.vimrc`

### macOS Window Management
- **AeroSpace**: `osx/.aerospace.toml` - Tiling window manager with extensive workspace keybindings
- **Hammerspoon**: `osx/.hammerspoon/init.lua` - Window manipulation and automation
- **neru**: `universal/.config/neru/config.toml` - modal keyboard-navigation overlay

### Development Tools
- **Git**: `universal/.gitconfig` (per-machine `[user]`/credentials live in the unstowed `.gitconfig.local`) and `universal/.gitignore_global`. Worktree helpers `clone-wt`/`clean-wt` aliases invoke `~/.local/bin/{clone-for-wt,clean-merged-wt}`.
- **Ripgrep**: `universal/.ripgreprc` for search configuration

### Agents (agent-agnostic)
- Skills are split across two source trees: `universal/.agents/skills/` (agent-agnostic) and `rblx/.agents/skills/` (Roblox-specific: `automated-reviewer`, `pr-review-doc`, `investigate-grafana-anomaly`, `voice-server-docs`). `bootstrap.sh`'s `agents_dots` stows both into `~/.agents/` and `~/.claude/skills/`, guarded on `rblx/.agents/skills/` existing. `AGENTS.md` as a file symlink, and each `skills/<skill>` as a **directory symlink** (see the folding note under Claude Code). **`.agents/AGENTS.md` is the one home for agent-agnostic standing instructions** — Codex reads it natively; Claude Code can't, so `universal/.claude/CLAUDE.md` imports it (below). Add standing instructions there, never per-agent. Note: `~/.agents` (dotted, agent config) is distinct from `~/agents` (no dot, the synced work-doc workspace / `AGENT_WORK_DIR`).
- Codex only discovers a skill when its *directory* is a symlink (a real dir containing a symlinked `SKILL.md` is ignored), which is why each `~/.agents/skills/<skill>` is folded into a directory symlink rather than linked file-by-file.

### Claude Code
- `universal/.claude/` is stowed into `~/.claude/`: `settings.json` (thinking/effort defaults, plugins, hooks), `hooks/notify-tmux.sh` (surfaces run state in the tmux window name + bell), and `CLAUDE.md`. Machine-local overrides belong in the unstowed `~/.claude/settings.local.json`.
- **`universal/.claude/CLAUDE.md` is a stub whose only content is `@~/.agents/AGENTS.md`** plus an HTML comment. `~/.claude/CLAUDE.md` is user-scope, so it loads every session and gives Claude Code the agent-agnostic instructions Codex gets natively — one source of truth, no parallel copy. User-scope imports are exempt from the external-import approval dialog, so importing a path outside the cwd is fine here. Claude-*specific* standing instructions go below the comment under `## Claude Code`; path-scoped ones stay in `.claude/rules/` (only `rblx/` ships any now — `cpp-style-guide.md`, `voice-sfu.md`). `universal/.claude/rules/` was deleted when `references.md`, a byte-identical copy of the `## References` section in `.agents/AGENTS.md`, became redundant under the import.
- `universal_dots` prunes broken symlinks in `~/.claude/rules/`: stow's unstow pass only removes links whose package file still exists, so deleting a `rules/*.md` from the repo leaves a dangling link that Claude Code still tries to load. That dir, unlike `~/.claude/skills`, is not shared with the Roblox skill manager.
- Claude Code reads `~/.claude/skills`, which is a **shared** dir also populated by the Roblox skill manager. `agents_dots` stows the `skills` package from each source (`universal/.agents` and, when present, `rblx/.agents`) into both `~/.agents/skills` and `~/.claude/skills` with folding enabled (i.e. *without* `--no-folding`), so each `skills/<skill>` becomes a single **directory symlink** into the dotfiles tree — matching the Roblox manager's own convention (its entries are directory symlinks too). The shared `~/.claude/skills` stays a real dir, so folding touches only our skill entries and leaves Roblox-managed symlinks alone. `agents_dots` also removes any stale real skill dirs left by the old `--no-folding` layout (only our entries, never the manager's) since a pre-existing real dir would block folding. `universal_dots` ignores `.agents` entirely (`universal/.stow-local-ignore`), so this is the only place `~/.agents` and our `~/.claude/skills` entries are managed. `rblx/.stow-local-ignore` likewise excludes `.agents` from the home-dir stow pass.
- Worktree hooks `universal/.local/bin/_worktree-hook-{create,remove}` are wired to `WorktreeCreate`/`WorktreeRemove`; they route bare-hub feature worktrees through `_worktree`/`_worktree-rm` and pass everything else through plain `git worktree` commands.

#### Work-management skill suite

`universal/.agents/skills/` holds the agent-agnostic suite that moves work from idea → shippable PR, writing living docs to a cross-project workspace **outside any repo** under `~/agents/` (work management only, never committed). Roblox-specific skills (`automated-reviewer`, `pr-review-doc`, `investigate-grafana-anomaly`, `voice-server-docs`) live in `rblx/.agents/skills/` and are only stowed when the `rblx/` directory exists:

- **`research`** → investigate a question, write findings to `$AGENT_WORK_DIR/research`, present an overview.
- **`plan`** → decompose research (or a raw task) into an actionable, user-guided plan + work items in `$AGENT_WORK_DIR/plans`; may create JIRA only with permission. Carries a live roll-up of its work items.
- **`handoff`** → a living doc for one shippable unit (a PR) in `$AGENT_WORK_DIR/handoffs`; the crash/context-loss recovery artifact.
- **`pickup`** → resume work by matching the current branch/worktree to a handoff, summarizing state, and asking how to proceed (or initializing a handoff from a plan / adhoc when none exists).

Two buckets sit outside that chain, defined in `agent-docs`: `$AGENT_WORK_DIR/reviews` (our review of *someone else's* branch) and `$AGENT_WORK_DIR/artifacts` (one-off scripts, utilities, diagrams — no metadata, always linked from the doc that motivated it). `artifacts/` was renamed from `scripts/` on 2026-08-04. `reviews/` is half-owned: an ad-hoc review of a working diff is still just `/code-review` / `/security-review` output persisted there when it's long or multi-pass, but the PR-review path is owned by the pair below.

The single base var `AGENT_WORK_DIR` (`~/agents`) is exported in `universal/.zshenv`; each skill appends its subdir. The workspace documents itself in `~/agents/AGENTS.md` (agent-agnostic source of truth: dir layout, doc conventions summary, archive/cleanup procedure); `~/agents/CLAUDE.md` is a stub containing only `@AGENTS.md` plus an HTML comment, since Claude Code reads `CLAUDE.md` and not `AGENTS.md`. Both live in **`universal/agents/`** (undotted) and are the only versioned files in the otherwise-unversioned `~/agents`:

- **`universal/agents/` → `~/agents/` (the work-doc workspace)** vs **`universal/.agents/` → `~/.agents/` (agent config: `AGENTS.md` + skills)**. The dot is the only difference in both the package names and the targets; the two are unrelated, and `agents_dots` handles only the dotted one.
- No bootstrap wiring was needed for the undotted package: `universal/.stow-local-ignore`'s `\.agents` entry is anchored, so it ignores `.agents` without matching `agents`, and `universal_dots` picks it up. `--no-folding` keeps `~/agents` a real dir and links only the two files, leaving the unversioned siblings alone.
- **Any `~/agents` sync backend must ignore both paths** (see the sync contract below) so each machine links its own clone — the dotfiles checkout does not need to live at the same path on macOS and the devspace. Syncing them instead would compare two symlinks whose targets legitimately differ, conflicting on every run.
- `universal_dots` backs up a real (non-symlink) `~/agents/{AGENTS,CLAUDE}.md` to `.bak` before stowing, since both existed as real files pre-migration and Unison had already replicated them.
- Keep the two files in the same package dir: `CLAUDE.md`'s bare `@AGENTS.md` import resolves logically (`~/agents/AGENTS.md`, the sibling symlink) *and* physically (`universal/agents/AGENTS.md`, the sibling real file). Splitting them breaks one of those.

Shared conventions (metadata block, status vocab, filenames, lifecycle, cleanup sweep) live in the **`agent-docs`** skill (`skills/agent-docs/SKILL.md`) — the **single source of truth**, which the four skills above reference by relative path. Its review-doc section is written for *machine-maintained* docs generally (either review skill below), not `automated-reviewer` specifically, so a doc started by hand from a PR URL and one from a queue sweep are the same artifact. It's a real skill rather than a bare resource doc for two reasons: its `description` is then always in context, so an agent writing a work doc *without* invoking one of the four still knows the conventions exist; and it's directly invokable as `/agent-docs`. Project-specific doc skills (e.g. `voice-server-docs`) override these defaults in their scope.

A `SKILL.md` alone only makes it discoverable, not applied — breadth needs an always-loaded pointer, and there is exactly **one**: the "Work-management docs" section of `universal/.agents/AGENTS.md`, which reaches Codex natively and Claude Code through the `~/.claude/CLAUDE.md` import. Keep that section to a pointer; anything longer belongs in `agent-docs`.

`~/agents/AGENTS.md` is deliberately **only a pointer** to the `agent-docs` skill plus the facts that are local to that directory (which files are stow-versioned, `prompts/` being workspace-local). It was originally a ~120-line restatement of the conventions; that was cut on 2026-08-04 because two copies drift. Its one unique section, the on-request "clean up the workspace" sweep, moved into `agent-docs`' Lifecycle. Resist re-growing it.

#### Review skills — `pr-review-doc` + `automated-reviewer`

PR review is split into a **primitive** and an **orchestrator**, decoupled on 2026-08-12 so a PR can be reviewed by name and not only by arriving in the review queue:

- **`pr-review-doc`** (per-PR primitive) — point it at any PR (`/pr-review-doc <URL|OWNER/REPO#N> [repo path]`) and it resolves it, fetches refs, builds the grounding brief (JIRA via `atlassian`, cross-repo patterns via Sourcegraph, convention rules for the changed paths), delegates the diff pass to `code-review`, and writes/updates the review doc under `~/agents/reviews/`. Owns the manifest→`review_state` mapping, since that is per-PR logic. Reconciles only the doc it touches, and never archives.
- **`automated-reviewer`** (queue orchestrator) — owns discovery (`gh search prs --review-requested`), the dedup union with existing docs, the queue-wide `review_state`/`approvals` sweep, archive-on-close, and the batch summary. Its per-PR steps collapse to one line: follow `pr-review-doc` with the already-resolved manifest entry (passing the entry, not a URL, halves the GitHub reads).

Both drive **one resolver**, `pr-review-doc/scripts/review_targets.py` (renamed from `automated-reviewer/scripts/direct_review_requests.py`), so queue and one-off paths deduplicate identically on `(canonical PR URL, head SHA)`. It lives in the primitive and is referenced by the orchestrator — dependencies point orchestrator → primitive, not the reverse. `--pr URL|OWNER/REPO#N` (repeatable) bypasses the queue search, skips the existing-doc union (naming one PR should resolve one PR), and marks entries `requested: true`, which exempts them from the team-only exclusion and makes `--fetch` unconditional; `--user` now defaults to the authenticated `gh` login. Before the split, `--user` was required and `discover()` always began with the queue search, so the per-PR half was unreachable without a queue hit — that, not the prose, was the actual coupling. Skills invoke the resolver by absolute path (`~/.agents/skills/pr-review-doc/scripts/…`), not a cwd-relative one.

**The reviewer never writes to GitHub.** The guarantee is structural, not a request: all GitHub access goes through the resolver (GET-only — `gh search prs`, `gh pr view`, `gh api …/reviews`, `gh api user`), and `code-review` is independently git-only, so "never invoke bare `gh`" covers the whole surface. Writes are confined to `refs/review-requests/*` and `~/agents/`. The old "read-only unless the user separately authorizes a write" escape hatch was deliberately removed — posting is a separate act, and the game-engine repo's own `review-pr` skill is the one that creates pending reviews and inline comments. That collision is why ours is named `pr-review-doc`: two similarly-named skills with opposite write behavior is the likeliest route to an accidental comment on someone else's PR. (`~/.agents/AGENTS.md`'s "review-pr or code-review" line refers to the repo-local one.) No hook or `permissions.deny` enforcement was added — a session-wide block would also break legitimately prompted posting elsewhere.

`code-review` (from the Roblox `user-communities-skills` marketplace) references `pr-checkout` and `code-highlight` skills that are **not installed** here. `pr-review-doc` fetching refs up front covers the `pr-checkout` gap; the citation-format gap is called out in its Known limitations.

#### `~/agents` sync — one contract, pluggable backends

Mac ↔ remote sync of `~/agents` is **per machine and opt-in**; nothing syncs unless a machine is configured for one backend. Run exactly one backend per remote (two tools writing the same tree will fight). Any backend must satisfy the same contract:

- **The remote gets real dirs.** Each `~/agents/<kind>` on a vault machine is an absolute symlink into the vault; the backend must carry the *contents*, so a vault-less remote (and its `agent-share` git repo, which would otherwise commit symlinks) sees ordinary directories.
- **Ignore set:** `AGENTS.md`/`CLAUDE.md` at the root (stow links), `.git` (the remote's publish repo), `.obsidian`, `review-queue.base`, `.review-cache`, `.review-repos`, plus `.DS_Store`/`*.tmp`/Obsidian `workspace*.json`. `.git` in particular must be ignored before a publish repo exists.
- Conflicts must be preserved, never silently dropped.

| Backend | Lives in | Used for | Enabled by |
| --- | --- | --- | --- |
| **Unison agent-sync** | `osx/` (generic; backports as-is) | any ssh-reachable remote, e.g. personal dev servers | creating `~/.config/agent-sync.conf` |
| **Coder Desktop Mutagen** | `rblx/` (work-only) | the work devspace, since 2026-10-12 | `agent-sync-coder start`, once |
| **Homebrew Mutagen** | `personal/` (public-only) | the personal dev box | `agent-sync-mutagen start`, once |

Backporting to the personal dotfiles means taking `osx/` + `bootstrap.sh` (Unison) and leaving `rblx/` (Mutagen) behind; nothing outside `rblx/` names a work host.

**Unison agent-sync** (`osx/`). The `~/.local/bin/agent-sync` wrapper drives a bidirectional `unison agents` sync using the profile `osx/.unison/agents.prf`, every 5 min (`StartInterval 300`) via a LaunchAgent. It satisfies the contract with `follow = Path <kind>` (symlinked kinds land as real dirs) and `ignore` lines, and `prefer = newer` plus central backups for conflicts. A machine opts in by creating the unstowed `~/.config/agent-sync.conf` (`REMOTE_HOST` / `REMOTE_PATH`); there are **no built-in defaults** (an old `coder-engine` default was removed), and the wrapper is a logged no-op without them. `agent_sync_init` installs the LaunchAgent only when that conf exists, and otherwise boots out and deletes any installed job — that is how a machine switches away from it. The profile **carries no roots or logfile path** — Unison expands neither `~` nor `$HOME` in a profile, so the wrapper passes both roots (building `ssh://$REMOTE_HOST/$REMOTE_PATH`, doubled slash preserving the absolute remote path) and `-logfile` on the command line. The plist is templated from `extra/launchd/com.agent-sync.plist.in` (`__HOME__` substituted by `agent_sync_init`, written into `~/Library/LaunchAgents`, not stowed, since launchd rejects symlinked plists); `agent_sync_init` also boots out the pre-rename `com.aciarlillo.agent-sync` job. It runs only in full bootstrap, not `dots` mode. The wrapper is a quiet no-op when the host is unreachable.

**Coder Desktop Mutagen** (`rblx/`, work Mac only). Sessions are declared in the Mutagen project file `rblx/.config/mutagen/agents.yml` (stowed to `~/.config/mutagen/agents.yml`) and driven by `rblx/.local/bin/agent-sync-coder [start|list|flush|pause|resume|reset|terminate]`. After the one-time `start` the app's daemon owns them; nothing runs from bootstrap.

- **Seven sessions, not one.** Mutagen never follows symlinks, so it can't use Unison's `follow` trick. Each kind has its own session from the real vault dir (`~/vault/10 - Agents/Work/<Kind>`) to `/home/coder/agents/<kind>`, and `agents-root` (`~/agents` ↔ `/home/coder/agents`) ignores the six kind names.
- **Betas use the Coder Connect hostname** (`dev.aciarlillo-engine.aciarlillo.coder`), not the `coder-engine` ssh alias: Coder Desktop launches its daemon with `MUTAGEN_SSH_CONFIG_PATH` set, so `~/.ssh/config` is not read.
- **The wrapper uses the app's bundled Mutagen binary and data dir** (`~/Library/Application Support/Coder Desktop/Mutagen`) so sessions live in the app's daemon and show in its UI. It sets `MUTAGEN_DISABLE_AUTOSTART=1` and fails if that daemon isn't running: a CLI-started daemon would lack the app's ssh environment and hold the lock the app needs. The app starts its daemon only when sessions already exist (Coder Connect on and the File Sync window open are not enough), so the very first `start` needs a throwaway GUI session to wake it; afterwards the project sessions keep it starting on launch.
- `mutagen project` writes `agents.yml.lock` beside the stowed link (in `~/.config/mutagen`, not the repo); `terminate`/`list` need it, so don't delete it while sessions exist.
- Mode is `two-way-safe` (conflicts surface and wait for a human) with VCS ignore on. Unlike Unison (`perms = 0`), Mutagen syncs the executable bit, so an exec-bit-only difference shows up as a conflict.

## Stow Management

Each platform directory contains a `.stow-local-ignore` file defining which files Stow should ignore during symlinking. This allows for selective file management within the same directory structure.

## Key Tool Integrations

The setup integrates several modern CLI and GUI tools:
- **ripgrep** for fast file search
- **fd** for fast file finding  
- **lsd** for enhanced directory listings
- **tmux** for terminal multiplexing
- **stow** for dotfile management
- **AeroSpace** for macOS window tiling
- **WezTerm** as primary terminal emulator

## Neovim Plugin Architecture

The Neovim setup uses LazyVim as a base with custom plugin configurations:
- Language servers configured in `lua/plugins/lsp.lua`
- GitHub integration via `lua/plugins/github.lua`
- Custom completion setup in `lua/plugins/completion.lua`
- UI enhancements and colorscheme management
- Copilot integration for AI assistance

## Platform-Specific Notes

**macOS**: Primary target. GUI integration via Hammerspoon automation, AeroSpace window management, and the neru keyboard overlay.

**Linux / devspaces**: Uses the shared `universal/` shell + terminal configs; the old i3/polybar desktop setup has been removed. On Linux, `bootstrap.sh` appends `exec /bin/zsh -l` to `.bashrc` when zsh is available.