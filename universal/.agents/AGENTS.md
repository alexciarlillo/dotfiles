# Agent instructions

## References

If I ask you to read a reference or file, URL, JIRA ticket, Confluence article or ANY document and you are not able to retrieve it, TELL ME so we can fix the issue. Do not just ignore or work without the reference material.

## Work-management docs

Research, plans, handoffs, and reviews are work management, not code. They live under
`$AGENT_WORK_DIR` (`~/agents`) and are **never** written into a repo or committed. One-off scripts,
utilities, and diagrams go in `$AGENT_WORK_DIR/artifacts` rather than being left loose in a repo.

Before creating or updating any of these, load the **`agent-docs`** skill for the shared conventions
(dirs, metadata block, status vocab, filenames, archive lifecycle) — including when writing one
adhoc, without going through `research` / `plan` / `handoff` / `pickup`. If a project-specific doc
skill scopes the area you're working in (e.g. `voice-server-docs`), it wins.

## Code Comments

All code comments should be limited to maximum of 80 characters per line and no more than 3 lines per comment block.
Avoid references to external documents in code comments.
Avoid referencing past conversations or decisions in code comments.
Code comments should be self-contained and explain the "why" behind the code, not just the "what".

## PR Comments

Do not automatically reply to comments when addressing PR feedback unless prompted to do so.
Do not automatically post comments to PRs you are reviewing unless prompted to do so.

## Code Reviews

All code reviews done using the review-pr or code-review skills should generate a corresponding review document in `$AGENT_WORK_DIR/reviews` with a link to the PR and a summary of the review.
All references to issues should include links to the relevant locations or commits in the GitHub diff.
