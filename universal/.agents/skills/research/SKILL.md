---
name: research
description: Investigate a question or problem space and capture the findings in a research doc under ~/agents/research/, then present an overview. Use when the user wants to explore, scope, or evaluate work we MIGHT do before committing to a plan — "research X", "look into Y", "is Z worth doing", "what are our options for W". Not tied to a branch or ticket.
argument-hint: 'What should I research?'
---

# Research a question and capture the findings

Read `../agent-docs/SKILL.md` first — it defines the workspace dirs, metadata block, filenames,
and lifecycle shared across the `research → plan → handoff → pickup` suite. **Defer to any
project-specific doc skill** (e.g. `voice-server-docs`) that applies to the area you're researching.

The argument is the research question. Research is exploratory: it captures work we *might* do — not
tied to a branch or ticket, and it may never be prioritized (that's fine — it ends `dropped`).

## Do the research

Use whatever tools fit the question — don't reinvent existing skills:

- **`deep-research`** for heavy, multi-source, fact-checked external research.
- **`atlassian`** (JIRA/Confluence), **`glean`**, **Sourcegraph MCP**, **`repo-analyze`** for internal
  context, prior art, and cross-repo code search.
- Local `grep`/Read for the current repo.

Verify claims against a real source and note where each finding came from. Prefer conclusions over
raw dumps.

## Write the doc

Save to `$AGENT_WORK_DIR/research/<slug>.md` (fall back to `~/agents/research/`; `mkdir -p` first).
Descriptive `kebab-case` filename, no ticket prefix. Lead with the metadata block (`Type: research`,
`Status: exploring`, `Last verified:`, `Verified against:`), then:

- **Question / Scope** — what we're answering and the boundaries.
- **Method & sources** — how you looked; link sources by URL/path.
- **Findings** — what you learned, with evidence.
- **Options & recommendation** — the realistic paths forward and which you'd pick.
- **Cost / risk / effort** — a rough sizing so it can be prioritized (or not).
- **Open questions** — what's still unknown.
- **Warrants a plan?** — a short verdict: worth planning now, later, or drop.

## Present & hand off

Summarize the findings and recommendation in chat (the doc has the detail). Then offer the next step:
`/plan <path-to-this-doc>` to decompose it into actionable work — noting it's fine to leave it as
`exploring`/`dropped` if it isn't worth building. Do not start planning or implementation
automatically.
