---
name: plan
description: Decompose a research doc or a raw task into an actionable, user-guided plan and a set of work items (each ≈ one PR ≈ loosely one JIRA issue), saved under ~/agents/plans/. Use when the user wants to turn findings or a goal into a concrete, sequenced plan of shippable units. May create JIRA tickets, but only after explicit permission.
argument-hint: 'A research doc path, or the task to plan'
---

# Decompose work into an actionable plan

Read `../agent-docs/SKILL.md` first — workspace dirs, metadata block, filenames, and lifecycle
for the `research → plan → handoff → pickup` suite. **Defer to any project-specific doc skill** (e.g.
`voice-server-docs`) for the area being planned.

The argument is either a path to a research doc or a raw task description. Research is optional — you
can plan straight from a goal. This step is **interactive and user-guided**: confirm scope and
sequencing with the user; don't unilaterally decide the shape of the work.

## Build the plan

1. If given a research doc, Read it and carry its recommendation forward (link it, don't duplicate).
   If starting from a raw task, gather just enough context (`repo-analyze`, Sourcegraph, `atlassian`
   for existing tickets) to decompose responsibly.
2. **Decompose into work items** where each item ≈ **one handoff ≈ one PR ≈ (loosely) one JIRA
   issue** — small enough to ship independently. Establish sequencing and dependencies between them.
3. Confirm the decomposition, scope, and ordering with the user before finalizing.

## JIRA — permission required

You **may** create a JIRA epic/issues for the work items via the `atlassian` skill, but **only after
explicit user permission** — never silently. You may freely *pull* existing ticket context. When the
user approves, create the tickets and record their keys in the plan's roll-up table.

## Write the doc

Save to `$AGENT_WORK_DIR/plans/<slug>.md` (fall back to `~/agents/plans/`; `mkdir -p` first). Descriptive
`kebab-case` filename. Lead with the metadata block (`Type: plan`, `Status: active`, `Research:`
back-ref if any, `Last verified:`, `Verified against:`), then:

- **Goal / Context** — what we're building and why; link the research by path.
- **Work-item decomposition** — the items, each with a crisp definition of done.
- **Sequencing & dependencies** — order, what blocks what, what can go in parallel.
- **Status roll-up** — a live table, one row per work item. This is the "current state" surface that
  handoff agents refresh as they ship:

  | Work item | Handoff doc | Branch | Ticket | PR | State |
  |-----------|-------------|--------|--------|----|-------|
  | … | `~/agents/handoffs/…` (once created) | … | KEY | #… | not-started / in-progress / in-review / merged / blocked |

## Present & hand off

Summarize the plan and the ordered work items. Then offer to **initialize handoffs** for the ready
items (`/handoff` per item — each becomes a living PR doc that back-references this plan) and, if not
already done, offer to create JIRA tickets (with permission). Do not start implementation
automatically.
