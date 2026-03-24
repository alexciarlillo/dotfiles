
[[ -r ~/.config/zsh/znap ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.config/zsh/znap

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

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

case `uname` in
    Darwin)
        export PATH="$PATH:$HOME/.nvm/current/bin"
        export PATH="$PATH:$HOME/.local/bin"
        export PATH="$PATH:$HOME/.dotnet/tools"
        # Roblox utilities 
        source $HOME/.config/zsh/rbx
        export RBX_LOCAL_NUGET_FEED=/Users/${USER}/.rbx/LocalNuGetRepo
        # nvm
        [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
    ;;
    Linux)
        # Linux specific config
        export TERM=xterm-256color
        export EDITOR="vim"
        export GIT_SSH=/usr/bin/ssh

        export PATH="$PATH:$HOME/.local/bin"
    ;;
esac

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
znap prompt


# Custom completions for dco and dcc wrappers
fpath=(~/.config/zsh/completions $fpath)

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/alex/.docker/completions $fpath)
# autoload -Uz compinit
# compinit
# End of Docker CLI completions

