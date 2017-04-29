source "$HOME/.dotfiles/antigen/antigen.zsh"

export DISABLE_AUTO_TITLE="true"

antigen-use oh-my-zsh
antigen theme afowler

antigen-bundle git
antigen-bundle docker
antigen-bundle vagrant
antigen-bundle node
antigen-bundle npm
antigen-bundle sudo

antigen-apply

export TERM=xterm-256color
export EDITOR="vim"
export GIT_SSH=/usr/bin/ssh
export PATH=${PATH}:~/development/tools/android-sdk-linux/tools
export PATH=${PATH}:~/development/tools/android-sdk-linux/platform-tools
export PATH=${PATH}:~/.composer/vendor/bin

local user='%{$fg[magenta]%}%n@%{$fg[magenta]%}%m%{$reset_color%}'
local pwd='%{$fg[blue]%}%~%{$reset_color%}'
export PSTEST="${user} ${pwd}$ "

setxkbmap -option ctrl:nocaps

bindkey "^[[7~" beginning-of-line
bindkey "^[[8~" end-of-line

. /etc/infinality-settings.sh

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
