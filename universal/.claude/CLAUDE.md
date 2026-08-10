@~/.agents/AGENTS.md

<!--
Deliberately a stub. `~/.agents/AGENTS.md` holds the agent-agnostic standing instructions and is
the single source of truth: Codex reads it natively, Claude Code does not, so this file imports it
instead of keeping a parallel copy under `.claude/rules/`.

Imports in user-scope memory files load without the external-import approval dialog, so pulling in
a path outside the working directory is fine here (it would prompt once from a project CLAUDE.md).

Anything that applies to every agent belongs in `universal/.agents/AGENTS.md`. Put Claude-specific
instructions below this comment, under a `## Claude Code` heading. Path-scoped or Claude-only rules
still belong in `.claude/rules/` (see `rblx/.claude/rules/` for scoped examples).
-->
