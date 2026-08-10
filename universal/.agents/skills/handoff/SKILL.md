---
name: handoff
description: Create or update a living handoff document for one shippable unit of work — a single PR (JIRA-optional). Captures how to pick up and continue the task, and is the recovery artifact for a crashed session or lost context. Saved under ~/agents/handoffs/. Use when compacting the current work into a doc another agent (or a future you) can continue.
argument-hint: 'What will the next session be used for?'
---

# Write a living handoff document

Read `../agent-docs/SKILL.md` first — it defines the workspace dirs, metadata block, filenames,
and lifecycle shared across the `research → plan → handoff → pickup` suite. **Defer to any
project-specific doc skill** (e.g. `voice-server-docs`) that scopes the area you're working in — it
may dictate where handoffs go and what they must contain; follow it instead of these defaults.

A handoff is scoped to **exactly one shippable unit of work — a single PR** (which may or may not be
tied to a JIRA issue). Broader, multi-PR implementation context belongs in a **plan** doc under
`~/agents/plans/` — reference it by path, don't inline it. If the work spans several PRs, that's a
plan with several handoffs, not one big handoff.

Two things that are *not* handoffs: reviewing **someone else's** branch (that's `~/agents/reviews/`,
when the review is long or multi-pass), and non-doc byproducts like repro scripts, helper utilities,
or diagrams (those go in `~/agents/artifacts/` — see below).

A handoff is a **living document**: create it when you start, and keep updating it in place as the
work progresses. It exists so a fresh agent can recover the full state after a crash or context loss —
so it must always reflect *current* reality, not just the moment it was written.

## Save location & filename

Save to `$AGENT_WORK_DIR/handoffs/` (fall back to `~/agents/handoffs/`, or the OS temp dir as a last
resort). `mkdir -p` first. Filename: issue-key prefix when tied to a ticket —
`<ISSUE-KEY>-<topic>-handoff.md` (e.g. `CLI-212684-pr-handoff.md`); otherwise descriptive
`kebab-case-handoff.md` with a matching H1.

## Metadata block (required — this is what `pickup` binds on)

Lead with the H1, then the metadata block. For handoffs these fields are mandatory and must stay
accurate, because `pickup` discovers the doc by grepping them + the filename:

- `**Type:** handoff`
- `**Status:**` — `in-progress` / `blocked` / `in-review` / `merged` / `abandoned`
- `**Branch:**` — the git branch (`git branch --show-current`)
- `**Worktree:**` — the worktree path (`git rev-parse --show-toplevel`)
- `**Ticket:**` — issue key + URL, or `—`
- `**Plan:**` — path to the parent plan doc, if one exists
- `**Last verified:**` — date + ref you checked against

## Body

Keep it focused on "how to pick this up and finish the PR":

- **Status at a glance** — a short table of the PR(s) and their state (open/merged/blocked), mirroring
  the metadata `Status`. Update it as things move.
- **TL;DR** — where things stand and the single next action.
- **What's done / what's left** — enough to resume without re-deriving.
- **Gotchas / environment notes** — anything that would trip up a fresh agent.
- **Suggested skills** — skills the continuing agent should invoke.

Do not duplicate content already captured elsewhere (PRD, plan, ADR, issue, commits, diffs) — link by
path or URL. Redact secrets (API keys, passwords, PII).

## Artifacts

Don't inline a long repro script, helper utility, or diagram into the handoff, and don't leave it
loose in the repo. Save it to `$AGENT_WORK_DIR/artifacts/` (descriptive `kebab-case` + real
extension, executable if it's a script, with a header comment saying what it's for and how to run
it), then **link it from the handoff by path**. That link is what keeps it from becoming junk — an
artifact nothing references can't be told apart from leftovers.

## Keep the plan in sync

If this handoff back-references a plan, lightly refresh that plan's status roll-up row when the
handoff's state changes (branch, PR, merged/blocked) — the plan is the cross-item overview.

If the user passed arguments, treat them as what the next session will focus on and tailor the doc
accordingly.
