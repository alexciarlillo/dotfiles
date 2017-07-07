source "$HOME/.dotfiles/antigen/antigen.zsh"

export DISABLE_AUTO_TITLE="true"

antigen use oh-my-zsh
antigen theme https://github.com/caiogondim/bullet-train-oh-my-zsh-theme bullet-train

antigen bundle git
antigen bundle docker
antigen bundle vagrant
antigen bundle node
antigen bundle npm
antigen bundle sudo

BULLETTRAIN_PROMPT_CHAR=\$
BULLETTRAIN_CONTEXT_SHOW=false
BULLETTRAIN_TIME_SHOW=true
BULLETTRAIN_NVM_SHOW=false
BULLETTRAIN_RUBY_SHOW=false
BULLETTRAIN_DIR_BG=004
BULLETTRAIN_DIR_FG=015
BULLETTRAIN_GIT_BG=007
BULLETTRAIN_GIT_FG=000
BULLETTRAIN_TIME_BG=015
BULLETTRAIN_TIME_FG=000

BULLETTRAIN_PROMPT_ORDER=(
    time
    status
    custom
    dir
    git
)

antigen apply

export TERM=xterm-256color
export EDITOR="vim"
export GIT_SSH=/usr/bin/ssh

# add composer bins to path
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
# add rvm bins to path
export PATH="$PATH:$HOME/.rvm/bin"
# add yarn bins to path
export PATH="$PATH:$HOME/.yarn/bin"

local user='%{$fg[magenta]%}%n@%{$fg[magenta]%}%m%{$reset_color%}'
local pwd='%{$fg[blue]%}%~%{$reset_color%}'
export PSTEST="${user} ${pwd}$ "

setxkbmap -option ctrl:nocaps

bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line

# load NVM
export NVM_DIR="/home/ciarlill/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# load RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 

