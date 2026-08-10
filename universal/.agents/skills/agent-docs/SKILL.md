---
name: agent-docs
description: Shared conventions for the work-management workspace under ~/agents/ (research → plan → handoff → pickup, plus reviews and artifacts) — where each kind lives, the metadata block, status vocabulary, filenames, linking, and the archive lifecycle. Read before creating or updating any research, plan, handoff, or review doc, or saving a one-off script/diagram, including adhoc ones written without invoking those skills. Defer to a project-specific doc skill (e.g. voice-server-docs) when one scopes the area you're working in.
---

# Agent work-management docs — shared conventions

Shared spec for the work-management skill suite: **`research` → `plan` → `handoff` → `pickup`**.
Those four skills point here for the cross-cutting rules instead of duplicating them. Read it directly
when you're writing or updating a work doc *without* going through one of them.

The suite moves a piece of work from *idea* → *shippable PR* while staying flexible: the full path is
`research → plan → 1+ handoffs → 1+ pickups`, but you can skip research (`plan` straight from a task),
or go fully adhoc (`handoff`/`pickup` with no backing doc). Nothing forces a doc to exist upstream.

Two buckets sit **outside** that chain because they aren't our own shippable work: `reviews/` (our
feedback on someone else's branch) and `artifacts/` (things that aren't docs at all). Both are
described under "Where docs live".

## Where docs live

All doc kinds live in a flat, cross-project workspace **outside any repo** (work management
only — never committed), under a single base dir `$AGENT_WORK_DIR` (`~/agents`):

```
$AGENT_WORK_DIR/                 (= ~/agents)
├── research/   ideas / specs / investigations we MIGHT do — not tied to a branch
├── plans/      decomposed, actionable plans; carry a live roll-up of their work items
├── handoffs/   one shippable unit of work = one PR; a LIVING doc, the crash-recovery artifact
├── reviews/    our review of SOMEONE ELSE'S branch — only when it's long or multi-pass
├── artifacts/  one-off scripts, helper utilities, diagrams — things that aren't docs
└── archives/   completed/retired work, moved out of the active dirs (see Lifecycle)
```

- One env var: `$AGENT_WORK_DIR`. Append the kind — `$AGENT_WORK_DIR/{research,plans,handoffs}`.
- If it's unset, fall back to `~/agents` (or the OS temp dir as a last resort for handoffs, matching
  the legacy behavior).
- Dirs are **flat and shared across every project** — filter by ticket key or topic slug, don't nest
  per-project.
- `mkdir -p` the target dir before writing — only `handoffs/` is guaranteed to exist today.
- `archives/` **mirrors the active dirs** (`archives/{research,plans,handoffs,reviews,artifacts}/`).
  Completed work is *moved* here, not deleted — see Lifecycle. (Some loose non-markdown artifacts
  predate `artifacts/` and still sit at the `archives/` root; new ones go in the mirror.)

### `reviews/` — reviewing someone else's branch

For **our review of someone else's** branch or PR — work that produces feedback for another person
rather than a change we ship, so it is *not* a handoff and has no plan above it. Use it **only when
the review is lengthy or spans multiple passes** and the notes need to survive between them; a quick
one-shot review belongs in chat, not a file.

The review *procedure* is a separate skill — `/review` for a GitHub PR, `/code-review` for a working
diff, `/security-review` for a security pass. `reviews/` is only where the **output** is persisted.

- Filename: `<KEY-or-PR>-<topic>-review.md` — e.g. `CLI-212684-teardown-review.md`, `pr-4821-review.md`.
- Metadata: `**Type:** review`, `**Status:** in-progress` / `delivered` / `abandoned`, plus
  `**Ticket:**`, `**Branch:**` / `**PR:**` (whose work you're reviewing — *not* your own), and
  `**Last verified:**` (the ref/SHA you reviewed, since the author keeps pushing).
- Body: track findings across passes with each one's state (open / addressed / withdrawn) so a second
  pass doesn't re-raise resolved points. Record which findings you actually posted.
- `delivered` once the feedback is posted → `archives/reviews/`.

### `artifacts/` — everything that isn't a doc

Catch-all for things agents produce that don't fit any doc kind: one-off repro/helper scripts,
throwaway utilities, diagrams, exported data, tarballs. No metadata block and no status — these
aren't docs.

- Descriptive `kebab-case` filename with its real extension; keep scripts executable.
- **Always link an artifact from the doc that motivated it** (usually a handoff) by path, and have
  the artifact itself say in a header comment what it's for and how to run it. An unreferenced
  artifact is indistinguishable from junk.
- Archive alongside the work that produced it → `archives/artifacts/`.

## Defer to project-specific doc skills

If a skill scoped to the area you're working in dictates where its docs go and what they contain,
**follow it instead of these defaults** — e.g. Roblox Voice.Server work uses the `voice-server-docs`
skill, which layers issue-key filenames and an `origin/master` verification banner on top of this.

## Metadata block

Every doc leads with an H1 title, then a metadata block directly under it:

```markdown
# <Title>

**Type:** research | plan | handoff | review
**Status:** <see vocab below>
**Ticket:** KEY (url) — or `—` if none
**Branch:** <git branch>        ← handoff (ours) / review (theirs)
**Worktree:** <abs path>        ← handoff only
**PR:** <url or #num>           ← review only
**Author:** <who wrote it>      ← review only
**Plan:** <path>                ← handoff → its plan, if any
**Research:** <path>            ← plan → its research, if any
**Last verified:** <date> against <ref, e.g. origin/master (abc1234) / Sourcegraph / JIRA>
```

Include only the fields that apply. `Branch`/`Worktree`/`Ticket` on a handoff are what `pickup` binds
on, so keep them accurate. `artifacts/` files get no metadata block — they aren't docs.

## Status vocabulary

| Kind | Statuses |
|------|----------|
| research | `exploring` → `accepted` (spawned a plan) / `dropped` |
| plan | `active` / `blocked` / `complete` / `abandoned` |
| handoff | `in-progress` / `blocked` / `in-review` / `merged` / `abandoned` |
| review | `in-progress` → `delivered` (feedback posted) / `abandoned` |
| artifact | none — not a doc |

## Filenames

- **research & plans:** descriptive `kebab-case.md`, no ticket prefix (not branch-bound yet) —
  e.g. `announcement-audit-log.md`, `sdp-parse-optimization.md`.
- **handoffs:** issue-key prefix when tied to one — `<KEY>-<topic>-handoff.md`
  (e.g. `GRPS-2790-audit-log-handoff.md`); otherwise descriptive `kebab-case-handoff.md`.
- **reviews:** `<KEY-or-PR>-<topic>-review.md` — e.g. `CLI-212684-teardown-review.md`,
  `pr-4821-review.md`.
- **artifacts:** descriptive `kebab-case` + the real extension (`repro-uaf-asan.sh`,
  `teardown-sequence.excalidraw`) — no `-artifact` suffix.

## Linking, not duplication

Reference PRDs, plans, research, issues, commits, and diffs **by path or URL** — never inline broad
context. A handoff points at its plan by path; a plan points at its research by path and lists its
handoffs; research points forward at any plan it spawned. Redact secrets (API keys, passwords, PII).

## Lifecycle — graduate, don't accumulate

Completed work is **moved to `archives/<kind>/`** (preserving its kind), never deleted — these docs
live outside git, so archiving is how we keep history while the active dirs hold only *live* work.
Mark the terminal `**Status:**` first, then move:

- **research** `accepted` → spawns a plan (mark it `accepted`, link the plan). `dropped`, or work
  complete/deprioritized → the **user** moves it to `archives/research/` manually (not auto-archived).
- **plan** `complete` (no live handoff references remain) or `abandoned` → move to `archives/plans/`.
- **handoff** `merged` — verify the PR is merged (`git`/`gh`) **and** the JIRA ticket, if any, is
  closed (`atlassian`) — then move to `archives/handoffs/`. Never archive on a guess; if either is
  unmet or unverifiable, leave it and report what's blocking.
- **review** `delivered` (feedback posted) or `abandoned` → move to `archives/reviews/`. The other
  person's PR merging is *not* the trigger — our part ends when the feedback is out.
- **artifact** → move to `archives/artifacts/` when the work that produced it archives. An artifact
  with no doc referencing it anymore is a candidate to archive; flag it, don't delete it.

**Deletion is always the user's call** — the skills move to `archives/` and never auto-delete;
removing anything from `archives/` is up to the user. Confirm the set of moves before executing.

### Cleaning up the whole workspace on request

Asked to "clean up `~/agents`", apply the rules above as a sweep, in this order — handoffs first,
since whether a plan is done depends on its handoffs:

1. **Handoffs** — for each, check the PR is merged (`git`/`gh` against the metadata `Branch`/`PR`)
   **and** the ticket, if any, is closed (`atlassian`). Both hold → `merged` → `archives/handoffs/`.
2. **Plans** — no remaining live handoff references → `complete` → `archives/plans/`.
3. **Reviews** — feedback posted → `delivered` → `archives/reviews/`.
4. **Artifacts** — grep the active docs for each artifact's path; unreferenced ones are candidates.
5. **Research** — never auto-move; the user relocates it.

Present the full proposed set of moves and get confirmation before touching anything. Where you
can't verify a merge or a ticket state, leave the doc alone and say what's blocking — never archive
on a guess. This is deliberately guidance rather than a separate skill: an agent runs it on request.

## Cross-skill chaining

Each skill ends by *suggesting* the natural next step — it does not auto-run it:

- `research` → offer `/plan <this research doc>`
- `plan` → offer `/handoff` for each ready work item (and, with permission, JIRA tickets)
- any time → `/pickup` to resume in-flight work

An explicit argument lets the user say "just proceed" (e.g. `/pickup <instruction>`).
