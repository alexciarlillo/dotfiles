
[[ -r ~/.config/zsh/znap ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.config/zsh/znap

# Custom completions must be on fpath before compinit runs (via znap/oh-my-zsh)
fpath=(~/.config/zsh/completions $fpath)
[[ -d /Users/alex/.docker/completions ]] && fpath=(/Users/alex/.docker/completions $fpath)

source ~/.config/zsh/znap/znap.zsh

# install oh-my-zsh
znap source ohmyzsh/ohmyzsh
znap source ohmyzsh/ohmyzsh plugins/git

# Disable shared history across terminals
unsetopt share_history
setopt inc_append_history

ZSH_AUTOSUGGEST_STRATEGY=( history )
znap source zsh-users/zsh-autosuggestions

ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting

# load NVM
export NVM_DIR="$HOME/.nvm"
export NVM_SYMLINK_CURRENT=true
export NVM_AUTO_USE=true 
export NVM_LAZY_LOAD=true

# ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# agents
export AGENT_HANDOFF_DIR="$HOME/agents/handoffs"
[[ ! -d "$AGENT_HANDOFF_DIR" ]] && mkdir -p "$AGENT_HANDOFF_DIR"

# universal path exports
export PATH="$PATH:$HOME/.local/bin"

case `uname` in
    Darwin)
        export PATH="$PATH:$HOME/.dotnet/tools"
        # Roblox utilities 
        source $HOME/.config/zsh/rbx
        export RBX_LOCAL_NUGET_FEED=/Users/${USER}/.rbx/LocalNuGetRepo
        export RBX_GITHUB_USER=aciarlillo
        # nvm
        export PATH="$PATH:$HOME/.nvm/current/bin"
        [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
    ;;
    Linux)
        export TERM=xterm-256color
        export EDITOR="vim"
        export PATH="$PATH:$HOME/.cargo/bin"
    ;;
esac

# python :(
if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi

# aliases
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

znap eval starship 'starship init zsh'

# Custom completions and Docker CLI completions are loaded near the top,
# before znap/oh-my-zsh runs compinit.

