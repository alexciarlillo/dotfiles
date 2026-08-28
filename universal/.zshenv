
# LXC/Debian templates default to LANG=C, which leaves tmux out of UTF-8 mode
# (#{client_utf8} == 0) so it mangles multibyte glyphs. Only fill in a UTF-8
# locale if the environment (e.g. ssh AcceptEnv from the client) has none.
if [[ $LANG != *[Uu][Tt][Ff]* ]]; then
    export LANG=C.UTF-8
fi

export PATH="$PATH:$HOME/.local/bin"

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

export AGENT_WORK_DIR="$HOME/agents"  # research/, plans/, handoffs/ live under here

case $(uname) in
    Darwin)
        export PATH="$PATH:$HOME/.dotnet/tools"
        export PATH="$PATH:$HOME/.nvm/current/bin"  # node/npm for all shells; nvm itself is handled in ~/.config/zsh/nvm
        ;;
    Linux)
        export TERM=xterm-256color
        export EDITOR="vim"
        ;;
esac

if [[ -d "$HOME/.cargo" ]]; then
    export CARGO_HOME="$HOME/.cargo"
    [[ -d $CARGO_HOME/bin ]] && export PATH="$CARGO_HOME/bin:$PATH"

    if [[ -f "$CARGO_HOME/env" ]]; then
      . "$CARGO_HOME/env"
    fi
fi

if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Private env exports (non-interactive safe)
if [[ -d "$HOME/.config/zsh/env.d" ]]; then
    for f in "$HOME/.config/zsh/env.d"/*.zsh(N); do
        . "$f"
    done
fi

. "$HOME/.cargo/env"
. "$HOME/.rokit/env"
