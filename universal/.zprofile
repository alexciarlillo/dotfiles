# Homebrew — placed in .zprofile so it runs AFTER /etc/zprofile's path_helper,
# ensuring /opt/homebrew/bin wins over /usr/local/bin and system paths.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
