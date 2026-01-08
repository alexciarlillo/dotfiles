
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
znap source lukechilds/zsh-nvm

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
        export RBX_LOCAL_NUGET_FEED=/Users/${USER}/.rbx/LocalNuGetRepo
        # Guilded commands
        # source $HOME/GitHub/guilded/guilded/guilded_profile.sh
        # Roblox commands 
        source $HOME/.rbx-zsh
    ;;
    Linux)
        # Linux specific config

        export TERM=xterm-256color
        export EDITOR="vim"
        export GIT_SSH=/usr/bin/ssh

        # add rvm bins to path
        export PATH="$PATH:$HOME/.rvm/bin"
        # add yarn bins to path
        export PATH="$PATH:$HOME/.yarn/bin"
        # add pip packages
        export PATH="$PATH:$HOME/.local/bin"

        local user='%{$fg[magenta]%}%n@%{$fg[magenta]%}%m%{$reset_color%}'
        local pwd='%{$fg[blue]%}%~%{$reset_color%}'
        export PSTEST="${user} ${pwd}$ "

        setxkbmap -option ctrl:nocaps

        bindkey "^[[7~" beginning-of-line
        bindkey "^[[8~" end-of-line

        # load RVM
        [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
    ;;
esac

# override guilded use_required_node_version with no-op 
use_required_node_version() {
    return 0
}


if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

# Load tmux sessionizer functions
if [ -f ~/.config/tmux/tmux-sessionizer ]; then
    . ~/.config/tmux/tmux-sessionizer
fi


if [ -f ~/.config/tmux/tmux-workspace-helper ]; then
    . ~/.config/tmux/tmux-workspace-helper
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

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

if type complete &>/dev/null; then
  _npm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###
