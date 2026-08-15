---
name: automated-reviewer
description: Find open GitHub Enterprise pull requests where an individual user is directly requested as a reviewer, exclude team-only requests, deduplicate them against local review documents by canonical PR URL and head SHA, prepare local git refs, then ground each review in the wider system — Sourcegraph cross-repo patterns, your engineering convention rules, and the linked JIRA ticket — before delegating the line-by-line pass to the code-review skill. Use to audit, review, or document a user's direct review queue across repositories without modifying GitHub.
---

# Automated Reviewer — Direct Review Request Documenter

Discover and prepare reviews deterministically, **ground each one in the system it touches**, then
apply human review judgment with the `code-review` skill. This skill is the review-queue foundation
that a paired reviewer (e.g. a BuilderUI cron reviewer) can reference: it owns discovery,
deduplication, ref-prep, grounding, and the review-document contract — it does **not** re-implement
the diff-level review, which stays with `code-review`.

## Workflow

1. Read all applicable user and repository `AGENTS.md` and `CLAUDE.md` files.
2. Read `../agent-docs/SKILL.md` before creating or updating review documents — it owns the
   `~/agents/reviews/` bucket, filename (`<KEY-or-PR>-<topic>-review.md`), and metadata format,
   including the `**Last verified:**` SHA marker the driver deduplicates on. Read any scoped
   documentation skill required by repository instructions.
3. Run the bundled driver. Start without `--fetch` to inspect the manifest:

   ```bash
   python3 scripts/direct_review_requests.py \
     --user pcarr --host github.rbx.com --reviews-dir ~/agents/reviews \
     --output /tmp/direct-review-manifest.json
   ```

4. Inspect the manifest. It verifies that `reviewRequests` contains a `User` whose login exactly
   matches `--user`; search results caused only by a requested team are excluded (`excluded_team_only`).
5. For each `needs_review` or `head_changed` entry, map its repository and fetch immutable local refs
   when useful:

   ```bash
   python3 scripts/direct_review_requests.py ... --fetch \
     --repo GameEngine/game-engine=/absolute/path/to/worktree
   ```

   The driver does not check out branches. It fetches the PR head and base into refs under
   `refs/review-requests/` and records those refs in the manifest.

6. Determine scope. Skip `already_reviewed` entries. For `head_changed`, review only the range from
   `previous_head_sha` to `head_sha` when it is available, and update `existing_document`. For
   `needs_review`, review the full PR and create one document.

7. **Ground the review** (do this before invoking `code-review`, for every non-skipped PR). The
   `code-review` skill is deliberately git-only and diff-scoped — it reads the code, not the system.
   This is where principal-engineer judgment comes from: understand what you're touching, then feed
   that context in. Assemble a short **grounding brief** from:
   - **JIRA ticket** — derive the key from the PR title, branch name, or body (e.g. `ABC-1234`). Use
     the `atlassian` skill to pull the ticket's intent and acceptance criteria, then judge whether the
     PR actually satisfies the ask (not just whether the diff is internally correct).
   - **Sourcegraph** — search the touched symbols, APIs, and patterns across Roblox repos
     (`mcp__mcp-gateway-sourcegraph__search` / `get_file`). Answer: is this how we do it elsewhere? Is
     there a canonical API or helper this duplicates? Is there prior art or an established pattern the
     change should follow? This is the DRY and consistency lens.
   - **Convention rules** — load the engineering convention rules that apply to the changed paths from
     the user/repo `CLAUDE.md` (C# services, testing, validation, error-handling, DRY). Treat clear,
     quotable rule violations in changed code as high-signal findings.

   Keep the brief tight — a few bullets of system context and the specific rules/patterns in play — and
   avoid narration. It is review context, not review output.

8. Invoke `code-review` separately for every non-skipped PR, passing the grounding brief from step 7
   as the review context and rubric. `code-review` handles the diff mechanics; the brief supplies the
   system-level judgment (ticket intent, cross-repo consistency, convention rules). Keep all GitHub
   operations read-only unless the user separately authorizes a write.
9. Record the exact canonical `url` and label the exact SHA as `Reviewed head` (or use the established
   `**Last verified:** <SHA>` form) in every review document. Preserve the document format and location
   dictated by `../agent-docs/SKILL.md` and scoped instructions.
10. Re-run the driver immediately before finishing. If a head changed during review, inspect the new
    range and update the same document before reporting completion.
11. Summarize documents created or updated with PR URLs, skipped PRs, and explicitly state when no new
    reviews were needed.

## Driver contract

- Treat `(canonical PR URL, reviewed head SHA)` as the deduplication key.
- Use `--repo OWNER/REPO=PATH` repeatedly. Omitted repositories remain discoverable but are not fetched.
- Treat the JSON manifest as coordination data, not as review output.
- A failed fetch is reported per PR and does not erase discovery results.
- Do not pass `--fetch` when only queue discovery or deduplication is requested.

When parallel review is explicitly requested or permitted, assign exclusive PRs or whole repositories
to workers. Keep discovery, deduplication, final head verification, and document validation centralized
so two workers never update the same document.

## Known limitations

- For a force-pushed / rebased PR, `head_changed` derives `previous_head_sha` from the first
  `**Last verified:**`-style SHA found in the review document, and does not detect base-branch moves.
  In practice a document carries a single verified SHA, so the range stays correct; if a document ever
  records multiple, confirm the baseline SHA before reviewing only a range.
