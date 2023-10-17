[[ -r ~/.config/zsh/znap ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.config/zsh/znap

source ~/.config/zsh/znap/znap.zsh
# install oh-my-zsh
znap source ohmyzsh/ohmyzsh 
znap source ohmyzsh/ohmyzsh plugins/git

ZSH_AUTOSUGGEST_STRATEGY=( history )
znap source zsh-users/zsh-autosuggestions

ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting

# load NVM
export NVM_DIR="$HOME/.nvm"
export NVM_SYMLINK_CURRENT=true

# ripgrep config
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

case `uname` in
    Darwin)
        export NVM_AUTO_USE=true
        export PATH="$PATH:/usr/local/opt/postgresql@12.10/bin"
        export PATH="$PATH:$HOME/.nvm/current/bin"
        export ANDROID_HOME="$HOME/Library/Android/sdk"
        export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
        export PATH="$PATH:$ANDROID_HOME/emulator"
        export PATH="$PATH:$ANDROID_HOME/tools"
        export PATH="$PATH:$ANDROID_HOME/tools/bin"
        export PATH="$PATH:$ANDROID_HOME/platform-tools"
        export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
        export PATH="$PATH:$HOME/code/src/googlesource/depot_tools"
        export PATH=$(brew --prefix ruby)/bin:$(brew --prefix)/lib/ruby/gems/3.2.0/bin:$PATH
        export JAVA_HOME_11_X64=$(/usr/libexec/java_home -v 11)
        export JAVA_HOME_17_X64=$(/usr/libexec/java_home -v 17)
        # Guilded commands
        source $HOME/code/src/github/TeamGuilded/guilded/guilded_profile.sh
        cd $HOME

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


if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

aliasNvm

znap eval starship 'starship init zsh'
znap prompt
