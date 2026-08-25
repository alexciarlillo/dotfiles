# Keep Git-derived tmux window names synchronized with the shell's directory.
_tmux_smart_window_name_chpwd() {
    [[ -n "${TMUX_PANE:-}" ]] || return
    command tmux-smart-window-name --update "$TMUX_PANE" >/dev/null 2>&1
}

autoload -Uz add-zsh-hook
add-zsh-hook -d chpwd _tmux_smart_window_name_chpwd 2>/dev/null
add-zsh-hook chpwd _tmux_smart_window_name_chpwd
