
[[ -r ~/.config/zsh/znap ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.config/zsh/znap

# Custom completions must be on fpath before compinit runs (via znap)
fpath=(~/.config/zsh/completions $fpath)
[[ -d /Users/$HOME/.docker/completions ]] && fpath=(/Users/$HOME/.docker/completions $fpath)

source ~/.config/zsh/znap/znap.zsh

# --- History ---
# Set explicitly here: dropping oh-my-zsh removed its lib/history.zsh, which was
# providing HISTSIZE/SAVEHIST and hist options. Without this we fall back to
# macOS /etc/zshrc's tiny HISTSIZE=2000/SAVEHIST=1000.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000        # entries kept in memory
SAVEHIST=50000        # entries persisted to file

setopt extended_history       # record timestamps
setopt inc_append_history     # append each command as it's entered
setopt hist_ignore_all_dups   # dedupe — better autosuggestions
setopt hist_ignore_space      # ignore commands starting with a space
setopt hist_reduce_blanks
unsetopt share_history        # no live cross-terminal sync; new shells still read the full file at startup

ZSH_AUTOSUGGEST_STRATEGY=( history )
znap source zsh-users/zsh-autosuggestions

ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting

# agents work-management workspace (research/, plans/, handoffs/)
[[ -n "$AGENT_WORK_DIR" ]] && mkdir -p "$AGENT_WORK_DIR"/{research,plans,handoffs}

# python (interactive shell init)
if [[ -d "$HOME/.pyenv" ]]; then
    eval "$(pyenv init - zsh)"
fi

# generic aliases
if [ -f ~/.config/zsh/aliases ]; then
    . ~/.config/zsh/aliases
fi

# git aliases and functions
if [ -f ~/.config/zsh/git ]; then
    . ~/.config/zsh/git
fi

# tmux helpers and functions
if [ -f ~/.config/zsh/tmux ]; then
    . ~/.config/zsh/tmux
fi

# nvm (lazy load + .nvmrc auto-use)
if [ -f ~/.config/zsh/nvm ]; then
    . ~/.config/zsh/nvm
fi

# Private interactive shell configs
if [[ -d "$HOME/.config/zsh/interactive.d" ]]; then
    for f in "$HOME/.config/zsh/interactive.d"/*.zsh(N); do
        . "$f"
    done
fi

znap eval starship 'starship init zsh'

# Custom completions and Docker CLI completions are loaded near the top,
# before znap/oh-my-zsh runs compinit.


# Added by declawd
export PATH="$HOME/.local/bin:$PATH"
