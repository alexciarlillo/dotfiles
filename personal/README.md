# personal/ — personal-only overlay

Stow package for config that exists **only** in the public (personal)
dotfiles. It has no counterpart in the canonical work repo, so:

- `bootstrap.sh` stows it via `overlay_dots` (guarded on the dir existing), and
  `overlay_init` sources `extra/personal/setup.sh` on full bootstrap.
- `backport-public` passes `--exclude=/personal/ --exclude=/extra/personal/` to
  its `rsync --delete`, so a backport leaves both in place. That exclude lives
  in canonical; without it a backport deletes this dir.

Keep docs for anything in here in this file, not the top-level README/CLAUDE.md,
which canonical overwrites on every backport.

## ~/agents ↔ dev.local (Mutagen)

Bidirectional sync of `~/agents` with `dev.local:/home/alex/agents`, the
personal counterpart of the work repo's Coder Desktop Mutagen backend. It
replaces Unison agent-sync on this Mac; never run both (`agent-sync-mutagen
start` refuses while `~/.config/agent-sync.conf` exists).

- **Project:** `.config/mutagen/agents-personal.yml` → `~/.config/mutagen/`.
  Nine sessions: one per vaulted kind (Mutagen never follows the
  `~/agents/<kind>` → vault symlinks, so each syncs from the real vault dir),
  `agents-artifacts`, and `agents-root` for whatever else sits at the top.
- **Wrapper:** `agent-sync-mutagen start|list|monitor|flush|pause|resume|reset|terminate|conflicts`.
- **Daemon:** Homebrew `mutagen`, registered as a login item by
  `extra/personal/setup.sh`. Uses the normal `~/.ssh/config` (`Host dev.local`).
- `mutagen project` writes `agents-personal.yml.lock` next to the stowed link;
  leave it while sessions exist.
- Mode `two-way-safe`: conflicting edits are held for you. `conflicts` prints
  one `ok`/`!!` line per session with any conflict paths, problems, or
  disconnects, and exits 1 when something needs attention.

### First-time setup

On the Mac:

    ./bootstrap.sh                     # installs mutagen, registers daemon, stows
    ssh -o BatchMode=yes dev.local true    # must succeed without a prompt

On dev.local (nothing to install — Mutagen copies its agent to
`~/.mutagen/agents/` over ssh on first connect):

    # Optional: snapshot before the first two-way merge.
    tar czf ~/agents-pre-mutagen.tgz -C ~ agents
    # If a Unison cron/timer ever wrote here, make sure it is gone.
    crontab -l 2>/dev/null | grep -i unison
    systemctl --user list-timers 2>/dev/null | grep -i -e unison -e agent

Then on the Mac:

    agent-sync-mutagen start
    agent-sync-mutagen list            # each session should reach "Watching"
    agent-sync-mutagen conflicts       # resolve anything listed by hand

### Switching off

    agent-sync-mutagen terminate
