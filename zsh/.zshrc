case `uname` in
    Darwin)
        source $(brew --prefix antigen)/share/antigen/antigen.zsh
        export NVM_AUTO_USE=true
    ;;
    Linux)
        source "$HOME/.dotfiles/antigen/antigen.zsh"
    ;;
esac

export DISABLE_AUTO_TITLE="true"

antigen use oh-my-zsh
antigen theme https://github.com/caiogondim/bullet-train-oh-my-zsh-theme bullet-train

antigen bundle git
antigen bundle docker
antigen bundle vagrant
antigen bundle node
antigen bundle npm
antigen bundle sudo
antigen bundle lukechilds/zsh-nvm

BULLETTRAIN_PROMPT_CHAR=\$
BULLETTRAIN_CONTEXT_SHOW=false
BULLETTRAIN_TIME_SHOW=false
BULLETTRAIN_NVM_SHOW=false
BULLETTRAIN_RUBY_SHOW=false
BULLETTRAIN_DIR_BG=004
BULLETTRAIN_DIR_FG=015
BULLETTRAIN_GIT_BG=015
BULLETTRAIN_GIT_FG=000
BULLETTRAIN_TIME_BG=015
BULLETTRAIN_TIME_FG=000

BULLETTRAIN_PROMPT_ORDER=(
    status
    custom
    dir
    git
)

antigen apply

# load NVM
export NVM_DIR="$HOME/.nvm"

case `uname` in
    Darwin)
        export PATH="/usr/local/opt/postgresql@9.6/bin:$PATH"
        # Guilded commands
        source $HOME/code/src/github/TeamGuilded/guilded/guilded_profile.sh
        cd $HOME
    ;;
    Linux)
        # Linux specific config

        export TERMINAL=kitty
        export TERM=xterm-256color
        export EDITOR="vim"
        export GIT_SSH=/usr/bin/ssh

        # add composer bins to path
        export PATH="$PATH:$HOME/.config/composer/vendor/bin"
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




if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

