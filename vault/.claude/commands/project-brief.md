---
description: Aggregate a project's context (Jira, Confluence, Docs, Slack, Todoist) into one brief to reason over.
argument-hint: [project name]
allowed-tools: Read, Glob, Write, Bash, WebFetch, Skill, mcp__todoist__*, mcp__mcp-gateway-slack__*
---

# Project Brief

Pull together everything known about a project into a single synthesized brief,
so I can ask questions against real context instead of hunting across tools.

## Input

- Project: ${1}
- Today: !`date +%Y-%m-%d`

## Steps

### 1. Load the hub

Find `01 - Projects/<project>/_Hub.md` (Glob `01 - Projects/*/_Hub.md` and match
if the name is approximate; if ambiguous, ask). Read its frontmatter, Links,
Documents table, and Log. Also read sibling notes in the project folder.

### 2. Fan out to the sources

Fetch live content for what the hub references. Cite every source with its link.
If a source can't be retrieved, note it explicitly — do not paper over gaps.

- **Jira** (`jira:` + any Documents rows) — summary, status, recent comments via
  the `atlassian` skill.
- **Confluence** (`confluence:` + rows) — page content via `atlassian`.
- **Google Docs** (rows) — content via the `gdrive` skill.
- **Slack** (`slack:` + Thread rows) — recent messages / thread via Slack MCP.
- **Todoist** — open tasks under `#Work` with the hub's `todoist_label`.
- **PRs / code** — `gh` via Bash, else WebFetch.

### 3. Synthesize

Produce a brief with:

- **State** — where the project is right now, in a few sentences.
- **Open questions & decisions needed** — gathered across the specs/docs, each
  with a link to its source.
- **What needs my attention** — docs in To Review / Reviewing, unanswered
  threads, stale items.
- **Open tasks** — the current Todoist list.
- **Source map** — every link consulted, grouped by tool.

## Output

Write the brief to `00 - Inbox/<Project> — Brief <today>.md`, and summarize the
highlights inline. Then stay available for follow-up questions grounded in what
you just gathered.
