---
name: pr-review-doc
description: Review one GitHub Enterprise pull request you name directly and write or update its review document under ~/agents/reviews/ — resolve the PR, fetch immutable local refs, ground the pass in the linked JIRA ticket, Sourcegraph cross-repo patterns, and the convention rules covering the changed paths, then delegate the line-by-line diff pass to the code-review skill. Strictly read-only against GitHub: never comments, approves, requests changes, submits a pending review, or touches PR state. Use for a one-off review of a given PR URL or number, and as the per-PR engine the automated-reviewer queue skill drives. Not for posting feedback to GitHub — that is a different skill.
argument-hint: <PR URL or OWNER/REPO#NUMBER> [repo path]
---

# PR Review Document — review one PR, write the doc, touch nothing

Take a single pull request, **ground the review in the system it touches**, delegate the diff pass to
`code-review`, and persist the result as a review document. This is the per-PR primitive:
`automated-reviewer` owns the review *queue* and drives this skill once per PR, but the skill stands
alone — point it at any PR, whether or not anyone requested you as a reviewer.

It does **not** re-implement the diff-level review (that stays with `code-review`) and it does **not**
own the document schema (that stays with `agent-docs`).

## Read-only contract — no GitHub writes, ever

This skill only ever *reads* GitHub. That is not a default to be argued out of: a review pass that can
write is a review pass that eventually comments on the wrong line of someone else's PR.

- **Never invoke `gh` directly.** Every GitHub read goes through this skill's
  `scripts/review_targets.py` (`~/.agents/skills/pr-review-doc/scripts/review_targets.py`), which
  issues only GETs. `code-review` is independently git-only. Between them the entire GitHub surface is
  accounted for, so a bare `gh` in this workflow is by definition out of contract.
- **Never** run `gh pr review`, `gh pr comment`, `gh pr edit`, `gh pr close`, `gh pr merge`,
  `gh pr ready`, `gh pr lock`, `gh issue comment`, `gh api` with `--method`/`-X` anything but `GET`,
  or any equivalent HTTP call. No approving, no requesting changes, no *pending* reviews, no labels,
  no assignees, no draft toggles, no re-request dismissals.
- **Writes are limited to** local git refs under `refs/review-requests/` (only via `--fetch`) and
  files under `$AGENT_WORK_DIR` (`~/agents`). Nothing else: no commits, no branches, no pushes, no
  edits to the working tree of the repository under review, and no changes to the PR author's code.
- Asked mid-review to post the feedback: **stop and say this skill does not post.** Posting is a
  separate, deliberate act — hand the findings back and let the user post them, or use a skill built
  for it (the game-engine repo's `review-pr` creates pending reviews). Do not "just this once".
- Read-only extends to the ticket: the `atlassian` skill is used to **read** the JIRA issue. Do not
  comment on it or transition it.

## Usage

```
/pr-review-doc https://github.rbx.com/GameEngine/game-engine/pull/170573
/pr-review-doc GameEngine/game-engine#170573 ~/GitHub/roblox/game-engine/main
```

A PR URL or `OWNER/REPO#NUMBER` is required — this skill never guesses which PR you meant. The
optional second argument is the local clone or worktree for that repository, used for ref fetching;
without it, resolution still works and the diff pass falls back to whatever refs already exist.

**Driven by `automated-reviewer`:** it passes a manifest entry it already resolved. Use that entry as
given and skip step 1 — re-resolving would double the GitHub reads for every PR in the queue.

## Workflow

1. **Resolve the PR.** Skip when handed a manifest entry.

   ```bash
   python3 ~/.agents/skills/pr-review-doc/scripts/review_targets.py --pr GameEngine/game-engine#170573 \
     --reviews-dir ~/agents/reviews --output /tmp/pr-review-target.json
   ```

   `--user` defaults to the authenticated `gh` login; pass it to resolve as someone else. Explicit
   `--pr` mode skips the review-request queue search entirely, so a PR nobody assigned you resolves
   normally, and the entry is never dropped as team-only.

   Read the entry's `status`, `pr_state`, `head_sha`, `existing_document`, and `previous_head_sha`. An
   entry carrying a `resolution_error` has unknown (`null`) review state — report it and stop rather
   than writing a document from partial data.

2. **Read the conventions.** All applicable user and repository `AGENTS.md` / `CLAUDE.md` files, then
   `../agent-docs/SKILL.md` for the `~/agents/reviews/` bucket, the filename
   (`<KEY-or-PR>-<topic>-review.md`), and the frontmatter schema. Load any scoped documentation skill
   the repository instructions require (e.g. `voice-server-docs` for Voice.Server paths).

3. **Fetch refs** when a local clone is available. Re-run step 1 with the repo mapping:

   ```bash
   python3 ~/.agents/skills/pr-review-doc/scripts/review_targets.py --pr GameEngine/game-engine#170573 ... --fetch \
     --repo GameEngine/game-engine=/absolute/path/to/worktree
   ```

   The head and base land in `refs/review-requests/<owner>-<repo>/<number>/{head,base}` and are
   recorded in the entry's `fetch` block. Nothing is checked out and no branch moves. Because the refs
   already exist, hand them to `code-review` directly rather than having it re-derive the PR tip.

4. **Determine scope** from `status`:

   | `status` | scope |
   |----------|-------|
   | `needs_review` | the full PR: `git merge-base <base ref> <head ref>` → head ref |
   | `head_changed` | only `previous_head_sha` → `head_sha` when that SHA is fetchable, else the full PR; update the existing document |
   | `already_reviewed` | the current head is already documented — re-review only if the user explicitly asked for this PR anyway, and say so; otherwise stop after step 8 |

   Diff from the **merge base**, never from the base ref directly. `--fetch` fetches the live base
   branch, which has usually moved past the PR's fork point, so `base..head` would fold unrelated
   commits into the review and produce findings on code the author never touched.

5. **Ground the review** — do this before invoking `code-review`. `code-review` is deliberately
   git-only and diff-scoped: it reads the code, not the system. This is where principal-engineer
   judgment comes from. Assemble a short **grounding brief** from:
   - **JIRA ticket** — derive the key from the PR title, branch name, or body (e.g. `ABC-1234`). Use
     the `atlassian` skill to read its intent and acceptance criteria, then judge whether the PR
     actually satisfies the ask, not just whether the diff is internally correct.
   - **Sourcegraph** — search the touched symbols, APIs, and patterns across Roblox repos
     (`mcp__mcp-gateway-sourcegraph__search` / `get_file`). Is this how we do it elsewhere? Is there a
     canonical helper this duplicates? Is there prior art the change should follow? The DRY and
     consistency lens.
   - **Convention rules** — the engineering rules that apply to the changed paths, from the user/repo
     `CLAUDE.md` and `.claude/rules/`. Clear, quotable rule violations in changed code are high-signal.

   Keep the brief tight — a few bullets of system context and the specific rules in play. It is review
   context, not review output; do not narrate it to the user.

6. **Invoke `code-review`**, passing the fetched refs, the scope from step 4, and the grounding brief
   as review context and rubric. `code-review` handles the diff mechanics and returns two buckets,
   `High-signal issues` and `Low-signal issues`.

7. **Write the document** under `~/agents/reviews/`, leading with the frontmatter schema in
   `../agent-docs/SKILL.md` ("Review-doc frontmatter"):
   - `verified_against` — the full 40-char head SHA you actually reviewed, quoted. It is the dedup key
     for every later run; wrong here means the PR gets re-reviewed or silently skipped.
   - `last_verified` — today's date, unquoted. `pr` — the entry's exact canonical `url`.
   - `findings_high` / `findings_low` — from the two buckets, writing `0` explicitly for an empty one.
     When updating an existing document, re-derive both from the whole body, not just this pass.
   - `draft` — the entry's `is_draft` boolean, so review views can distinguish PRs not ready for a full
     pass.
   - `status: in-progress` while the PR is open, even once feedback is delivered. Do not archive:
     terminal status and the move to `archives/reviews/` belong to `automated-reviewer`'s sweep.
   - Free-form context (base branch, previous head, what this pass covered) goes in the body under the
     H1, not the frontmatter.

8. **Reconcile `review_state`, `approvals`, and `draft`** for this one document. GitHub is
   authoritative, so overwrite a manual value it contradicts; leave a field untouched when the entry
   reports `null`.
   Copy `approvals` and `is_draft` (into `draft`) across on every run — other people approve and PRs
   leave draft without us doing anything, so those values go stale exactly when triage needs them.

   | entry | `review_state` |
   |-------|----------------|
   | `reviewed_by_user: true` | `reviewed` |
   | `reviewed_by_user: false`, `has_user_review: true` | `stale` |
   | `has_user_review: false` | `unreviewed` |

   A head move, a `DISMISSED` review, or a fresh direct re-request (`in_review_queue: true`) each make
   `reviewed_by_user` false and require another pass even when the head SHA did not change — all three
   land on `stale`. Note that `review_state` tracks whether **the human** submitted a GitHub review; it
   is not set by this skill having run, and this skill never makes it `reviewed`.

9. **Re-resolve before finishing.** If the head moved during the review, inspect the new range and
   update the same document before reporting.

10. **Report**: the document path, the PR URL, the `findings_high` / `findings_low` counts, the head
    SHA reviewed, and the scope covered (full PR or range). State plainly that nothing was posted to
    GitHub. Surface the findings themselves in chat — the document is a record, not a substitute for
    telling the user what you found.

## Resolver contract

- The dedup key is `(canonical PR URL, reviewed head SHA)`. The SHA is read from the document's
  frontmatter `verified_against:`, falling back to a legacy bold `**Verified against:**` field and then
  to a legacy `Reviewed head` / `PR tip` / `Last verified` 40-hex scrape. `existing_document_format`
  reports which matched — anything but `frontmatter` is a document due for conversion.
- Frontmatter is only recognized when `---` opens the file, so a horizontal rule mid-document is not
  mistaken for it.
- `--pr` accepts a full PR URL or `OWNER/REPO#NUMBER` (also `OWNER/REPO/NUMBER`), is repeatable, and
  overrides queue discovery. Entries it produces carry `requested: true`, and `mode` is `explicit`.
- `--fetch` fetches refs for explicit targets regardless of status or PR state, so re-reviewing a
  documented head or reading a merged PR after the fact both work.
- Only the user's **submitted** reviews count toward `reviewed_by_user`; pending ones do not.
  `approvals` counts reviewers currently standing as approving, from `latestReviews` (one entry per
  reviewer, so a later `COMMENTED` review does not displace an earlier approval and a dismissed
  approval drops out). It includes bots, is not restricted to the current head, and is `null` on an
  `unresolved` entry.
- `is_draft` is the PR's current draft state. It is a boolean when the PR resolves and is `null` on an
  `unresolved` entry.
- Treat the JSON manifest as coordination data, not as review output.
- The script never edits documents. Every document write is this skill's job.

## Known limitations

- The fetched `base` ref is the **live base branch**, not the PR's fork point, and the entry's
  `base_sha` is what GitHub reported at resolve time. Neither is a safe left-hand side for a diff —
  derive it with `git merge-base` (step 4).
- `previous_head_sha` comes from the first SHA in the document's `verified_against`. After a
  force-push the old head may no longer be fetchable; when it isn't, review the full PR rather than
  guessing a range. Base-branch moves are not detected.
- A document whose frontmatter parses but omits `verified_against` falls through to the legacy scans;
  if those miss too, the PR reads as `head_changed` with no `previous_head_sha` and gets a full
  re-review. `existing_document_format` is how you notice.
- `reviewed_by_user` reflects the head at resolve time. A push landing mid-review can leave the value
  stale; step 9 is what catches it.
- `code-review` references `pr-checkout` and `code-highlight` skills that are not installed here.
  Step 3 fetching the refs up front covers the `pr-checkout` gap; for citations, follow its format
  rules directly (`file_path:line` against the head ref) and verify line numbers with
  `git show <head-ref>:<path>`.
