---
name: pickup
description: Resume in-flight work by finding the handoff doc for the current branch/worktree, summarizing its state, and asking how to proceed (or just acting if told to). Use at the start of a session to continue a task — "pick up where I left off", "resume this branch", "what's the state of this work". Falls back to initializing a new handoff from a plan or an adhoc description when none exists.
argument-hint: 'Optional: an instruction, or a plan-doc path to start from'
---

# Pick up in-flight work

Read `../agent-docs/SKILL.md` first — workspace dirs, metadata block, filenames, and lifecycle
for the `research → plan → handoff → pickup` suite. **Defer to any project-specific doc skill** (e.g.
`voice-server-docs`) for the area you're resuming.

This is the entry point for continuing work. Discover the right handoff, summarize where things stand,
and either act on an explicit instruction or ask the user how to proceed.

## 1. Discover the handoff

Gather the binding signals for the current context:

```bash
git branch --show-current      # current branch
git rev-parse --show-toplevel  # worktree path
```

Then scan `$AGENT_WORK_DIR/handoffs/` (fall back to `~/agents/handoffs/`) and match a handoff by **both**
signals:

- grep the docs' metadata for `**Branch:**` / `**Worktree:**` / `**Ticket:**` equal to the current
  branch, worktree, or a ticket key derivable from the branch name;
- and match the branch / ticket key against handoff **filenames**.

## 2. Act on what you find

- **Exactly one match** → Read it, then present an overview: current `Status`, what's done, the next
  action, blockers, and its suggested skills. Then **ask the user how to proceed** — *unless* the
  skill was invoked with an argument telling you to do something specific, in which case just do it
  (still summarize the state briefly first).
- **Multiple matches** → list them (filename + one-line status) and ask which to pick up.
- **No match** → prompt the user. Two sub-cases:
  - The user points at (or the argument is) a **plan doc** → pick the relevant work item, then
    **initialize a new handoff** for it via the `handoff` skill, back-referencing the plan
    (`**Plan:**`) and filling in `Branch`/`Worktree`/`Ticket`. Then proceed.
  - **No plan either** → treat it as **adhoc**: initialize a handoff from the user's description via
    the `handoff` skill (no plan/ticket back-ref), then proceed.

## Arguments

- `/pickup` — discover → overview → ask how to proceed.
- `/pickup <instruction>` — discover → do the instruction (brief state summary first).
- `/pickup <plan-doc-path>` — no handoff yet → initialize one from that plan and proceed.

Keep the handoff a living doc: as you work, update its `Status` and body in place, and lightly refresh
the parent plan's roll-up row when state changes.
