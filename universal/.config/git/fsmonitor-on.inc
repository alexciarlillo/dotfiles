# Included by ~/.gitconfig (via includeIf gitdir) for large repos only.
# fsmonitor spawns a per-repo daemon that speeds up status/diff on big trees
# but adds a daemon cold-start that is pure overhead on small repos.
[core]
	fsmonitor = true
