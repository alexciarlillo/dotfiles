---
name: pickup
description: Resume in-flight work by finding the handoff doc for the current branch/worktree, summarizing its state, and asking how to proceed (or just acting if told to). A review-doc path opens that review read-only for discussion. Use at the start of a session to continue a task, inspect a review, or ask "what's the state of this work". Falls back to initializing a new handoff from a plan or an adhoc description when none exists.
argument-hint: 'Optional: an instruction, review-doc path, or plan-doc path'
---

# Pick up in-flight work

Read `../agent-docs/SKILL.md` first — workspace dirs, metadata block, filenames, and lifecycle
for the `research → plan → handoff → pickup` suite. **Defer to any project-specific doc skill** (e.g.
`voice-server-docs`) for the area you're resuming.

This is the entry point for continuing work or discussing a persisted review. Discover the right
handoff or open the named review, summarize where things stand, and either act on an explicit
instruction or ask the user how to proceed.

## 1. Handle an explicit review document

When the argument is an existing Markdown path under `$AGENT_WORK_DIR/reviews/` or
`$AGENT_WORK_DIR/archives/reviews/`, treat it as a **review document**, not a plan or a handoff.
Expand `~` and `$AGENT_WORK_DIR` before checking the path.

- Read the doc and present its PR URL, author, `status`, `review_state`, `draft`, verified head/date,
  and high-/low-signal finding counts. Summarize the open, addressed, and withdrawn findings so the
  user can discuss them without rereading the document.
- Ask what they would like to examine or do next. If they supplied an explicit instruction after the
  path, give the brief summary first, then follow it.
- Opening a review is **read-only**: do not initialize a handoff, alter the review's metadata or
  findings, archive it, or run the review queue. Follow `pr-review-doc` or `automated-reviewer` only
  when the user explicitly asks to refresh or continue the review itself.

An existing Markdown path outside those review directories is not a review-document argument; process
it under the handoff/plan rules below.

## 2. Discover the handoff

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

## 3. Act on what you find

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
- `/pickup <review-doc-path>` — open that review read-only → overview → ask what to discuss.
- `/pickup <review-doc-path> <instruction>` — open that review → brief overview → do the instruction.
- `/pickup <plan-doc-path>` — no handoff yet → initialize one from that plan and proceed.

Keep the handoff a living doc: as you work, update its `Status` and body in place, and lightly refresh
the parent plan's roll-up row when state changes.
