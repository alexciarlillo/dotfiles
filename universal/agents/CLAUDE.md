@AGENTS.md

<!--
Deliberately a stub. `AGENTS.md` is the agent-agnostic source of truth for this workspace and
every other agent reads it directly; Claude Code only reads CLAUDE.md, so this file imports it
rather than duplicating it. Put Claude-specific-only guidance below the import — anything that
applies to all agents belongs in AGENTS.md.

Both files are versioned in the dotfiles repo at universal/agents/ and stowed into ~/agents,
which is otherwise unversioned. The bare @AGENTS.md above resolves either way: logically it is
~/agents/AGENTS.md (the sibling symlink), physically it is universal/agents/AGENTS.md (the
sibling real file). Keep them in the same package dir or that stops being true.
-->
