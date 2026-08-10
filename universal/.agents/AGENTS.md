# Agent instructions

Agent-agnostic standing instructions — the single source of truth for every agent, and the only
place these belong. Codex reads this file natively at `~/.agents/AGENTS.md`; Claude Code doesn't, so
`~/.claude/CLAUDE.md` is a stub that imports it. Add standing instructions here, not in either
agent's own config. Grow this over time.

## References

If I ask you to read a reference or file, URL, JIRA ticket, Confluence article or ANY document and you are not able to retrieve it, TELL ME so we can fix the issue. Do not just ignore or work without the reference material.

## Work-management docs

Research, plans, handoffs, and reviews are work management, not code. They live under
`$AGENT_WORK_DIR` (`~/agents`) and are **never** written into a repo or committed. One-off scripts,
utilities, and diagrams go in `$AGENT_WORK_DIR/artifacts` rather than being left loose in a repo.

Before creating or updating any of these, load the **`agent-docs`** skill for the shared conventions
(dirs, metadata block, status vocab, filenames, archive lifecycle) — including when writing one
adhoc, without going through `research` / `plan` / `handoff` / `pickup`. If a project-specific doc
skill scopes the area you're working in (e.g. `voice-server-docs`), it wins.
