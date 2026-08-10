# Agent work-management workspace (`~/agents`)

The flat, **cross-project** workspace for agent work-management docs. It lives *outside any repo*
and is never committed. Dirs are shared across every project — filter by ticket key or topic slug
rather than nesting per-project.

```
~/agents/{research,plans,handoffs,reviews,artifacts,prompts,archives}/
```

## Conventions live in the `agent-docs` skill

**Read `~/.agents/skills/agent-docs/SKILL.md`** (Claude Code sees the same file at
`~/.claude/skills/agent-docs/SKILL.md`) before creating, updating, or restructuring anything in
here. It is the single source of truth for what each dir is for, the metadata block, status
vocabulary, filenames, linking, the archive lifecycle, and the on-request cleanup sweep.

Do **not** restate its rules in this file — that duplication is what this file was cut down to
avoid. If something here contradicts the skill, the skill wins.

The skills that write these docs are its siblings:
`~/.agents/skills/{research,plan,handoff,pickup}/SKILL.md`. Project-specific doc skills (e.g.
`voice-server-docs`) override the defaults within their scope.

## Local to this directory

- `AGENTS.md` and `CLAUDE.md` are **stow symlinks into the dotfiles repo** (`universal/agents/`)
  and are the only versioned files in here. Editing either one through `~/agents` writes straight
  into that repo: it needs committing, and it affects every machine. Unison ignores both paths so
  each machine links its own clone.
- `CLAUDE.md` is a stub that does nothing but `@AGENTS.md`, since Claude Code reads `CLAUDE.md`
  and not `AGENTS.md`. Keep the two files in the same package dir or that import breaks.
- Everything else here is unversioned and Unison-synced between the Mac and the devspace.
- `prompts/` (long-form prompts being drafted) is workspace-local and not part of the skill suite.
- `$AGENT_WORK_DIR` overrides the base dir; it defaults to `~/agents`.
