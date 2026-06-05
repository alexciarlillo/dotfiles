# Claude Code dotfiles

Stowed bits of `~/.claude/`. Two scripts that work together with the twork tmux setup to surface Claude's state at a glance.

## What you see

The tmux window name reflects Claude's state, mirrored across the matching window in the `edit`, `agent`, and `adhoc` twork sessions:

| State | Window name | How it clears |
|---|---|---|
| working | `⠋myproject` | flips to `myproject` on `Stop` |
| done | `myproject` + window flagged red | red flag clears when you focus the window |
| needs input | `?myproject` + window flagged red | both clear when you focus the window |

The "red flag" is tmux's built-in `monitor-bell` flag — `notify-tmux.sh` writes a BEL byte to a pane in each matching window, which `window-status-bell-style` (in `~/.config/tmux/tmux.conf.user`) renders as a red, reversed window-status entry. tmux clears the flag automatically the next time the window is selected. No glyph for "done" — the red flag is enough.

The bell-rendering settings (`monitor-bell on`, `bell-action other`, `window-status-bell-style`) live in `~/.config/tmux/tmux.conf.user`.

The `⠋` working glyph is intentionally space-less so the existing `after-select-window` sync hook in `twork-init` parses `agent:#{window_name}` as a single shell token. Spaces in the prefix would split it.

## `hooks/notify-tmux.sh`

Wired to `UserPromptSubmit`, `Stop`, and `Notification`:

- **`UserPromptSubmit`** — adds `⠋` prefix across all three sessions. Silent (no bell, no banner — you just hit enter).
- **`Stop`** — strips any prefix across all three sessions, rings the bell on a pane in each matching window, fires a "Claude finished" macOS banner with the Hero sound when unfocused.
- **`Notification`** — adds `?` prefix across all three sessions, rings the bell, fires a "Claude needs input" banner.

The macOS banner is suppressed when the originating pane is the currently-focused pane in any attached client (no banner spam while you're already looking at the response).

## `hooks/tmux-clear-indicator.sh`

Wired into tmux's `after-select-window` hook by `twork-init` (in `~/.config/zsh/tmux`). Strips the `?` prefix from the focused window's name across all three sessions. Working `⠋` is left alone — focusing while Claude is still thinking doesn't stop it. Done has no glyph to handle.

## One-time setup per machine

`~/.claude/settings.json` is intentionally **not** stowed (it holds per-machine state like `enabledPlugins`). Merge this into it:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify-tmux.sh" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify-tmux.sh" }] }
    ],
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify-tmux.sh" }] }
    ]
  }
}
```

Or with `jq`:

```bash
jq '.hooks = {
  UserPromptSubmit: [{ hooks: [{ type: "command", command: "~/.claude/hooks/notify-tmux.sh" }] }],
  Stop: [{ hooks: [{ type: "command", command: "~/.claude/hooks/notify-tmux.sh" }] }],
  Notification: [{ hooks: [{ type: "command", command: "~/.claude/hooks/notify-tmux.sh" }] }]
}' ~/.claude/settings.json > ~/.claude/settings.json.new && mv ~/.claude/settings.json.new ~/.claude/settings.json
```

If you already have twork sessions running when you pull this change, the `after-select-window` hook for clearing indicators won't be installed on them. Either restart tmux (`twork-nuke && start a new project`) or manually run the same `tmux set-hook -a ...` commands from `twork-init` against the live sessions.

## Smoke test

```bash
echo '{"hook_event_name":"UserPromptSubmit","cwd":"'"$PWD"'"}' | ~/.claude/hooks/notify-tmux.sh
echo '{"hook_event_name":"Stop","cwd":"'"$PWD"'"}'             | ~/.claude/hooks/notify-tmux.sh
echo '{"hook_event_name":"Notification","cwd":"'"$PWD"'"}'     | ~/.claude/hooks/notify-tmux.sh
```

From inside a tmux pane, each event should flip the indicator on the current window in both runtime + agent sessions. Stop/Notification also bell + banner (when unfocused). UserPromptSubmit is silent.
