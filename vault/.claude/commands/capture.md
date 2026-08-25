---
description: Capture a doc/spec/thread link into the right project hub and optionally create a Todoist task.
argument-hint: [url or text] [project name]
allowed-tools: Read, Write, Edit, Glob, Bash, WebFetch, Skill, mcp__todoist__*, mcp__mcp-gateway-slack__*
---

# Capture

Capture an incoming link (a spec to review, a design doc, a Jira ticket, a Slack
thread, a PR) into the correct project hub's **Documents** table, and optionally
create a matching Todoist next-action.

## Input

- Item: ${1}  (a URL, or freeform text describing what to capture)
- Project (optional): ${2}
- Today: !`date +%Y-%m-%d`

## Steps

### 1. Identify the source and resolve a real title

Detect the type from the URL and fetch its human-readable title. Never guess a
title — if you cannot retrieve it, tell me and ask rather than inventing one.

| URL pattern | Type | How to resolve title |
| --- | --- | --- |
| `*.atlassian.net/wiki/*` | Confluence | `atlassian` skill |
| `*.atlassian.net/browse/*`, bare Jira key | Jira | `atlassian` skill |
| `docs.google.com/*` | Google Doc | `gdrive` skill |
| `*.slack.com/archives/*` | Thread | Slack MCP (read the thread) |
| `github.rbx.com/*`, `sourcegraph.rbx.com/*` | PR / Code | `gh` via Bash, else WebFetch |
| anything else | Link | WebFetch for the page title |

Infer a Document **Type**: Spec · Proposal · Design · Meeting · PR · Thread.

### 2. Find the target project hub

- If ${2} is given, use `01 - Projects/<project>/_Hub.md`.
- Otherwise Glob `01 - Projects/*/_Hub.md`, read their titles/overviews, and pick
  the best match. If it's ambiguous, ask me — list the candidates.
- If no hub fits, ask whether to (a) start a new hub, or (b) park it in
  `00 - Inbox/`. Do not invent a hub silently.

### 3. Append to the Documents table

Add one row to the hub's `## Documents` table:

`| <Title> | <Type> | To Review | <link> |`

Use a wikilink if the target is an existing vault note; otherwise the URL. Bump
the hub's `updated:` frontmatter to today. Do not duplicate a row that already
links the same target.

### 4. Offer a Todoist task

If this is something I need to act on (review, respond, follow up), ask whether
to create a Todoist task. If yes, create it in the `#Work` project with the label
from the hub's `todoist_label`, titled like "Review: <Title>", including the
link. Never leave it in Inbox — always assign the label. Report the task link.

## Output

Confirm what was captured, which hub it landed in, and whether a task was created
(with links). If anything couldn't be resolved, say so plainly.
