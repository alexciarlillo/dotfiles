---
name: agent-docs
description: Shared conventions for the work-management workspace under ~/agents/ (research → plan → handoff → pickup, plus reviews and artifacts) — where each kind lives, the metadata block, the YAML frontmatter schema review docs use instead, status vocabulary, filenames, linking, and the archive lifecycle. Read before creating or updating any research, plan, handoff, or review doc, or saving a one-off script/diagram, including adhoc ones written without invoking those skills. Defer to a project-specific doc skill (e.g. voice-server-docs) when one scopes the area you're working in.
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
- Metadata: **YAML frontmatter**, not the bold block — see below. Review docs are currently the only
  kind that uses frontmatter.
- Body: track findings across passes with each one's state (open / addressed / withdrawn) so a second
  pass doesn't re-raise resolved points. Record which findings you actually posted. Keep them under
  the `High-signal issues` / `Low-signal issues` headings the review skills emit — those sections are
  what the `findings_high` / `findings_low` counts below are derived from.
- `delivered` once the feedback is posted → `archives/reviews/`.

#### Review-doc frontmatter

`~/agents` is an Obsidian vault, and the bold metadata block is invisible to its Properties UI and to
Bases queries. Review docs therefore lead with frontmatter, so the review queue is queryable:

```yaml
---
type: review
status: in-progress          # in-progress | delivered | abandoned
review_state: unreviewed     # unreviewed | reviewed | stale
findings_high: 1             # issue counts — always written, `0` included
findings_low: 3
approvals: 2                 # approvals from others, refreshed each run
draft: false                 # PR draft state, refreshed each run
ticket: CLI-219445           # omit both ticket fields when there is no ticket
ticket_url: https://roblox.atlassian.net/browse/CLI-219445
pr: https://github.rbx.com/GameEngine/game-engine/pull/170573
repo: GameEngine/game-engine
author: jiayuanli
branch: "jiayuanli/webrtc-m142-enable-ios"
last_verified: 2026-08-12
verified_against: "2384f65f372150f5bf2324b7f6871423ee02eda8"
---
```

- Lowercase `snake_case` keys; **unquoted** ISO dates, so Obsidian reads them as dates and sorts them.
- **Quote SHAs and branch names.** An all-digit SHA would otherwise parse as a number, and a branch
  containing `:` would break the YAML.
- `verified_against` is the full 40-char head SHA you reviewed — the review skills' dedup key. Keep it
  accurate or the PR gets re-reviewed.
- `findings_high` / `findings_low` are integer counts of the issues in the body's `High-signal issues`
  and `Low-signal issues` sections, so the queue shows at a glance which PRs actually have something
  to answer for. They are the **one exception to the omit rule below**: write `0` rather than dropping
  the key, because an empty property is indistinguishable from an unreviewed PR in a Base query — a
  clean review has to read as visibly clean. Omit them only before any review pass has finished.
- Keep the counts consistent with the body: a later pass that finds new issues raises them, a
  withdrawn finding lowers them, and marking one *addressed* does not (it was still discovered).
- `approvals` is how many *other* reviewers currently stand as approving — triage signal, so a PR that
  already has several can wait. Unlike everything else here it is a **snapshot of live state, not of
  our review**: it ages on its own, so the review skills refresh it on every run rather than only when
  writing a review — `automated-reviewer` across the whole queue. Hand-written review docs may omit it.
- `draft` is the PR's draft state as a boolean — a triage signal, since a draft PR is not ready for a
  full pass. Like `approvals` it is a **snapshot of live state**, refreshed by `pr-review-doc` for the
  document it touches and by `automated-reviewer` across the queue. Hand-written review docs may omit it.
- Omit fields that don't apply rather than writing `—`; an absent property reads as empty in a query.
- Structured fields only. Prose (e.g. a `**Review basis:**` note recording the base branch or a
  previous head) stays in the body, under the H1.

Other doc kinds still use the bold metadata block above — `pickup` discovers handoffs by grepping
`**Branch:**` / `**Worktree:**`, so converting them is a separate change, not a drive-by.

#### Machine-maintained review docs

Docs generated by the review skills — `pr-review-doc` for a single PR, or `automated-reviewer` driving
it across the direct-review queue — are machine-maintained, and override two of the rules above. Both
skills write the same document, so the two paths are interchangeable: a doc started by hand from a PR
URL is picked up and kept current by a later queue sweep, and vice versa.

- **`review_state`.** Tracks whether *the human* has reviewed the PR at its **current head**:

  | value | meaning |
  |-------|---------|
  | `unreviewed` | no submitted GitHub review from us on this PR |
  | `reviewed` | our latest submitted review is at the current head and still counts |
  | `stale` | we reviewed, but it no longer counts — the head moved, the review was dismissed, or we were directly re-requested |

  It is safe to edit by hand, but **GitHub is authoritative**: each run reconciles the value against
  the submitted reviews, overwriting one that GitHub contradicts. It is a *current-head* axis,
  independent of `status` — a doc can be `status: delivered` and `review_state: stale` at once.
- **Lifecycle: stay active while the PR is open.** Unlike a hand-written review, the doc stays
  `status: in-progress` for as long as the PR is open even after the feedback is delivered and
  `review_state` is `reviewed` — it must survive so a later head move can flip the state back to
  `stale` and surface another required pass. When the PR merges or closes, `automated-reviewer`'s sweep
  assigns the terminal status (`delivered` if we submitted any GitHub review on it, otherwise
  `abandoned`) and moves the doc to `archives/reviews/` without a separate move confirmation. Archival
  only — hard-deletion is still the user's call. `pr-review-doc` never archives: reviewing one PR is not
  the event that retires its document.

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

Research, plans, and handoffs lead with an H1 title, then a metadata block directly under it.
(**Review docs are the exception** — they use YAML frontmatter instead; see "Review-doc frontmatter"
above.)

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
**Last verified:** <date>
**Verified against:** <ref, e.g. origin/master (abc1234) / Sourcegraph / JIRA / a bare SHA>
```

Include only the fields that apply. `Branch`/`Worktree`/`Ticket` on a handoff are what `pickup` binds
on, so keep them accurate. `artifacts/` files get no metadata block — they aren't docs.

Verification is **two fields, not one prose line**: `Last verified` is the date alone, `Verified
against` is the ref alone. Keeping them separate makes the ref machine-parseable — in review docs it
is the full 40-char PR head SHA, and the review skills' shared resolver deduplicates on it.

## Status vocabulary

| Kind | Statuses |
|------|----------|
| research | `exploring` → `accepted` (spawned a plan) / `dropped` |
| plan | `active` / `blocked` / `complete` / `abandoned` |
| handoff | `in-progress` / `blocked` / `in-review` / `merged` / `abandoned` |
| review | `in-progress` → `delivered` (feedback posted) / `abandoned` |
| artifact | none — not a doc |

Review docs carry a second, orthogonal axis in `review_state` (`unreviewed` / `reviewed` / `stale`) —
whether *we* have reviewed the current head, which moves independently of `status`.

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
  person's PR merging is *not* the trigger — our part ends when the feedback is out. Exception:
  machine-maintained docs archive on the PR closing instead (see above).
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
