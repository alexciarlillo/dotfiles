#!/usr/bin/env bash
# Claude Code hook: surface Claude's state in the tmux window name + bell flag.
# UserPromptSubmit  → window name gets a "⠋" (working) prefix, no bell.
# Stop              → indicator stripped; bell rings in both twork sessions
#                     (tmux's monitor-bell flag turns the window red until focused).
# Notification      → window name gets a "?" (needs input) prefix; bell rings.
# Indicators are intentionally space-less ("⠋myproj") so the existing twork
# after-select-window sync hook still parses the window-name target as a
# single shell token.
#
# Target pane is identified by matching panes where the foreground command
# is claude (or a wrapper) and pane_current_path equals the hook payload's
# cwd. Falls back to basename(cwd) if no unique match, so a renamed tmux
# window still gets tracked as long as the pane is uniquely identifiable.
# Neither $TMUX nor $TMUX_PANE is consulted — not every harness propagates
# them, and process-tree walking via `ps` isn't always available either.
set -u

WORKING="⠋"
INPUT="?"

payload="$(cat)"
event="$(printf '%s' "$payload" | jq -r '.hook_event_name // "Stop"' 2>/dev/null || echo Stop)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // empty' 2>/dev/null || true)"
[ -z "${cwd:-}" ] && cwd="$PWD"
project="$(basename "$cwd")"

strip_indicator() {
  local n="$1"
  n="${n#"$WORKING"}"
  n="${n#"$INPUT"}"
  printf '%s' "$n"
}

# Rename matching-named windows across the runtime + agent twork sessions so
# the indicator (or its absence) shows wherever the user is attached.
rename_in_sessions() {
  local target="$1" newname="$2" session wid wname clean
  for session in edit agent adhoc; do
    while IFS=' ' read -r wid wname; do
      clean="$(strip_indicator "$wname")"
      if [ "$clean" = "$target" ]; then
        tmux rename-window -t "$wid" "$newname"
      fi
    done < <(tmux list-windows -t "$session" -F '#{window_id} #W' 2>/dev/null)
  done
}

# Write a BEL byte to the first pane's tty in each matching window. tmux's
# monitor-bell watches pane output for BEL and sets the window-bell flag,
# which window-status-bell-style renders red until the window is focused.
ring_bell_in_sessions() {
  local target="$1" session wid wname clean tty
  for session in edit agent adhoc; do
    while IFS=' ' read -r wid wname; do
      clean="$(strip_indicator "$wname")"
      if [ "$clean" = "$target" ]; then
        tty="$(tmux list-panes -t "$wid" -F '#{pane_tty}' 2>/dev/null | head -n1)"
        [ -n "$tty" ] && [ -w "$tty" ] && printf '\a' >"$tty" 2>/dev/null
      fi
    done < <(tmux list-windows -t "$session" -F '#{window_id} #W' 2>/dev/null)
  done
}

# Is any attached tmux client currently looking at a window whose cleaned
# name matches $project? Used to suppress the macOS banner when the user is
# already watching the pane that would have been notified.
# Identify the tmux pane running this claude process by finding panes whose
# foreground command is a claude wrapper AND whose pane_current_path equals
# the payload's cwd. Prints the cleaned window name if exactly one matches;
# empty otherwise. Uses `|` as a field separator so window names with spaces
# survive the round-trip.
find_my_window_name() {
  local want_cwd="$1" match_count=0 match_name="" wid wname cmd cpath
  while IFS='|' read -r wid wname cmd cpath; do
    case "$cmd" in
      declawd|claude|node) ;;
      *) continue ;;
    esac
    [ "$cpath" = "$want_cwd" ] || continue
    match_count=$((match_count + 1))
    match_name="$(strip_indicator "$wname")"
  done < <(tmux list-panes -a -F '#{window_id}|#W|#{pane_current_command}|#{pane_current_path}' 2>/dev/null)
  [ "$match_count" = 1 ] && printf '%s' "$match_name"
}

user_is_watching() {
  local target="$1" session w name wid matching=""
  for session in edit agent adhoc; do
    while IFS=' ' read -r w name; do
      [ "$(strip_indicator "$name")" = "$target" ] && matching="$matching $w"
    done < <(tmux list-windows -t "$session" -F '#{window_id} #W' 2>/dev/null)
  done
  [ -z "$matching" ] && return 1
  while IFS= read -r wid; do
    case "$matching " in *" $wid "*) return 0 ;; esac
  done < <(tmux list-clients -F '#{window_id}' 2>/dev/null)
  return 1
}

target="$(find_my_window_name "$cwd")"
[ -z "$target" ] && target="$project"

case "$event" in
  UserPromptSubmit) rename_in_sessions "$target" "$WORKING$target" ;;
  Stop)             rename_in_sessions "$target" "$target" ;;
  Notification)     rename_in_sessions "$target" "$INPUT$target" ;;
esac

# UserPromptSubmit only updates the window — no bell, no banner.
[ "$event" = "UserPromptSubmit" ] && exit 0

ring_bell_in_sessions "$target"

# macOS banner — skip when the user is already looking at the window.
user_is_watching "$target" && exit 0

if [ "$event" = "Notification" ]; then
  title="Claude needs input"
else
  title="Claude finished"
fi

osascript -e "display notification \"$project\" with title \"$title\" sound name \"Hero\"" >/dev/null 2>&1 || true
