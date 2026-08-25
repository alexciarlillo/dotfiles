# Export REMOTE_ID/REMOTE_DISPLAY/REMOTE_FG/REMOTE_BG for the current machine
# from ~/.config/remotes.conf, so tooling beyond starship/tmux can reference the
# resolved host identity. The prompt chip and tmux status bar call remote-badge
# directly and do not depend on these exports.
if command -v remote-badge >/dev/null 2>&1; then
    eval "$(remote-badge env)"
fi
