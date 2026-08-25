---
name: automated-reviewer
description: Find open GitHub Enterprise pull requests where an individual user is directly requested as a reviewer, exclude team-only requests, deduplicate them against local review documents by canonical PR URL and head SHA, then drive the pr-review-doc skill once per PR that still owes a pass. Also maintains those documents against GitHub across the whole queue: refreshes whether the human has reviewed each PR at its current head, how many approvals it has, and whether it is a draft; archives documents once the PR merges or closes. Strictly read-only against GitHub — never comments, approves, or changes PR state. Use to audit, sweep, or work through a user's direct review queue across repositories.
---

# Automated Reviewer — direct review queue

Own the review **queue**: discover what directly requests us, deduplicate it against the documents we
already keep, keep those documents true to GitHub, and retire them when the PR closes. The per-PR
review itself belongs to `../pr-review-doc/SKILL.md`, which this skill drives once per PR; the
diff-level pass belongs to `code-review`, which `pr-review-doc` drives in turn. This skill is the
foundation a paired reviewer (e.g. a BuilderUI cron reviewer) can reference for queue semantics.

Everything here is **read-only against GitHub** — the contract is spelled out in
`../pr-review-doc/SKILL.md` ("Read-only contract") and applies unchanged to this skill. No comments, no
approvals, no pending reviews, no state changes, and no bare `gh` invocations. Document writes and
archival moves under `~/agents/` are the only writes this skill makes.

## Workflow

1. Read all applicable user and repository `AGENTS.md` and `CLAUDE.md` files.
2. Read `../agent-docs/SKILL.md` — it owns the `~/agents/reviews/` bucket, the filename, and the
   frontmatter schema, including the `verified_against` SHA this skill deduplicates on, the
   `review_state` vocabulary, and the open-PR lifecycle for machine-maintained documents.
3. Run the resolver in queue mode. Start without `--fetch` to inspect the manifest:

   ```bash
   python3 ~/.agents/skills/pr-review-doc/scripts/review_targets.py \
     --user pcarr --host github.rbx.com --reviews-dir ~/agents/reviews \
     --output /tmp/direct-review-manifest.json
   ```

4. Inspect the manifest. It verifies that `reviewRequests` contains a `User` whose login exactly
   matches `--user`; queue results caused only by a requested team, and not already documented, are
   excluded (`excluded_team_only`). The work set is the **union** of that open queue and the PRs your
   existing documents track, so expect entries that are merged/closed or no longer requested —
   submitting a review removes you from the queue. Entries carrying a `resolution_error` (status
   `unresolved` when even `gh pr view` failed) have unknown, `null` review state: leave their
   documents untouched and report them.
5. **Sweep `review_state`, `approvals`, and `draft`** across the frontmatter of every existing document
   whose entry resolved without a `resolution_error` — including entries no pass is needed for. Apply
   the reconciliation rules in `../pr-review-doc/SKILL.md` step 8 (the manifest → `review_state` table,
   and copying `approvals` and `is_draft` into `draft` on every run). This queue-wide sweep is what
   keeps documents written days ago usable for triage; `pr-review-doc` only reconciles the single
   document it touches. Add any missing field to a managed document.
6. **Clean up closed PRs.** For each entry whose `pr_state` is `merged` or `closed` and that has an
   `existing_document` and no `resolution_error`: set frontmatter `status: delivered` when
   `has_user_review` is true, otherwise `status: abandoned`; then `mkdir -p ~/agents/archives/reviews/`
   and `mv` the document there. Leave `review_state` as reconciled — it can legitimately read `stale`
   on a `delivered` doc. This is archival and needs no separate move confirmation — never hard-delete.
   Skip these PRs for the rest of the workflow, and report the moved set in step 10.
7. Determine the work set: entries with status `needs_review` or `head_changed` whose `pr_state` is
   `open`. Skip `already_reviewed` — a document already recording the current head needs no new pass,
   only the step 5 sweep. Re-run the resolver with `--fetch` and a repo mapping per repository so the
   refs are in place before any review starts:

   ```bash
   python3 ~/.agents/skills/pr-review-doc/scripts/review_targets.py ... --fetch \
     --repo GameEngine/game-engine=/absolute/path/to/worktree
   ```

   Omitted repositories stay discoverable but are not fetched. The resolver does not check out
   branches; it fetches the PR head and base into refs under `refs/review-requests/`.
8. **For each PR in the work set, follow `../pr-review-doc/SKILL.md`, passing its manifest entry.**
   That skill owns scope selection, the grounding brief (JIRA, Sourcegraph, convention rules), the
   `code-review` delegation, and the document write. Pass the entry rather than a PR URL — it is
   already resolved, and re-resolving doubles the GitHub reads for every PR in the queue. Do not
   duplicate its steps here.
9. Re-run the resolver immediately before finishing. If a head changed during a review, hand that
   entry back to `pr-review-doc` to update the same document before reporting completion.
10. Summarize: documents created or updated with PR URLs and their `findings_high` / `findings_low`
    counts, documents archived by step 6 with their terminal status, `review_state` values changed by
    step 5, skipped PRs, and any `resolution_error` entries left untouched. State explicitly when no
    new reviews were needed, and that nothing was posted to GitHub.

## Queue contract

- Treat `(canonical PR URL, reviewed head SHA)` as the deduplication key. The document-parsing and
  per-entry review-state details are in `../pr-review-doc/SKILL.md` ("Resolver contract") — one
  resolver serves both skills, so the semantics are identical whether a PR arrives from the queue or
  by name.
- The work set is the union of the open `--review-requested` queue and the PRs referenced by documents
  in `--reviews-dir`, so reviewed, merged, and closed PRs stay resolvable. Explicit `--pr` mode
  deliberately skips that union — it is `pr-review-doc`'s entry point, not this skill's.
- Use `--repo OWNER/REPO=PATH` repeatedly, once per repository you want refs fetched into.
- Treat the JSON manifest as coordination data, not as review output.
- The resolver never edits documents — the reconciliation, status, and archival writes are this skill's
  job.
- A failed fetch is reported per PR and does not erase discovery results. A per-PR resolution failure
  yields `resolution_error` with `null` review state and does not abort the manifest; only a failed
  queue search fails the run, since that leaves the discovery set unknown.
- Do not pass `--fetch` when only queue discovery or deduplication is requested.

When parallel review is explicitly requested or permitted, assign exclusive PRs or whole repositories
to workers. Keep discovery, deduplication, the step 5 sweep, final head verification, and document
validation centralized so two workers never update the same document.

## Known limitations

- Documents already moved to `archives/reviews/` leave the union, so a re-opened PR is rediscovered as
  `needs_review` and gets a fresh document rather than reviving the archived one.
- `reviewed_by_user` reflects the head at manifest time. A push landing between the run and the
  reconciliation write can leave a stale value; the step 9 re-run catches it.
- The step 5 sweep can only reconcile documents whose PRs resolved. A GitHub outage mid-run leaves the
  rest of the queue carrying yesterday's `approvals`; report which ones, rather than assuming the
  sweep was complete.
- Per-PR limitations (force-push ranges, documents missing `verified_against`) are listed in
  `../pr-review-doc/SKILL.md`.
