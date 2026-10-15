# Personal-only bootstrap steps, sourced by bootstrap.sh's overlay_init (full
# bootstrap only). dev.local needs nothing: Mutagen pushes its own agent there.

if [[ "$(uname -s)" == "Darwin" ]]; then
  brew list mutagen >/dev/null 2>&1 || brew install mutagen-io/mutagen/mutagen
  # A login-started daemon keeps the agents-personal sessions alive.
  mutagen daemon register
  mutagen daemon start
fi
