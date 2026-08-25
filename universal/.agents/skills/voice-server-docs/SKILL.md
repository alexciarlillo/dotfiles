---
name: voice-server-docs
description: How and where to write, organize, and find durable docs (reference/architecture, research/specs, plans, handoffs) for Voice.Server — the in-house C++ WebRTC SFU at game-engine `Client/Voice/Server/`. Use ONLY when your task is in that area and you are about to create/update a design doc, plan, proposal, review, or handoff, OR you are looking for existing Voice.Server design notes. Handoffs, plans, and research live under `~/agents/{handoffs,plans,research}/`; durable reference lives in-repo at `Client/Voice/Server/docs/`.
---

# Voice.Server documentation — where docs go, and where to look

**Scope guard — read first.** This skill applies *only* when you are working on the Roblox engine's
**Voice.Server** SFU: your task touches `game-engine/Client/Voice/Server/` (the C++ WebRTC SFU that
replaces Janus). If you are not working in that area, this skill does not apply — ignore it.

## Baseline: the generic work-management suite

This skill **layers on top of** the shared `research` / `plan` / `handoff` / `pickup` suite. For the
workspace layout (`$AGENT_WORK_DIR/{research,plans,handoffs}`), the metadata block, status vocab,
filename rules, linking, and cross-skill chaining, follow the **`agent-docs`** skill
(`../agent-docs/SKILL.md`) — that is
the source of truth and applies here unchanged. Everything below is the Voice.Server-specific *delta*.

## The Voice.Server delta: in-repo durable reference

The suite's `$AGENT_WORK_DIR/{research,plans,handoffs}` is only half the picture for Voice.Server.
Durable reference — **how things ARE** — lives **in-repo and git-tracked** at
`Client/Voice/Server/docs/`, the **canonical source of truth**. The generic suite has no equivalent
bucket; this is the reason the skill exists.

| Bucket | For | Lives until |
|--------|-----|-------------|
| `Client/Voice/Server/docs/` (in-repo) | how something *is* — architecture, threading, protocol, test coverage, security posture | forever; update in place, in the same change as the code |
| `$AGENT_WORK_DIR/{research,plans,handoffs}` | per `agent-docs` (idea → plan → PR) | per `agent-docs`, with the graduation override below |

The other in-repo docs describe invariants for *editing* the code and should summarize + link into
`docs/` rather than duplicate it: `Client/Voice/Server/CLAUDE.md`, `Server_PREREAD.md`,
`tests/fuzz/CLAUDE.md`, `grafana/grafana.md`. Don't duplicate between them — cross-reference by path.

## Finding an existing doc

```
ls Client/Voice/Server/docs                             # durable reference (in-repo, canonical; linked from CLAUDE.md)
ls "$AGENT_WORK_DIR"/{handoffs,plans,research}          # agent workspace — then grep for the Voice topic / CLI-… key
```

## Voice-specific overrides to the shared conventions

- **Verify against `origin/master`, not local `master`.** The `Last verified:` / `Verified against:`
  banner (see `agent-docs`) must record **`origin/master`** — the local `master` worktree can be
  thousands of commits stale. Use `git show origin/master:<path>` / `git grep origin/master`.
- **Graduation folds into `docs/`, then deletes.** `agent-docs` says agent-workspace docs live outside
  git, so you mark a terminal `Status:` and let the user prune. For Voice.Server it's stronger: when a
  branch **merges**, fold the durable design into the relevant `Client/Voice/Server/docs/` doc and
  **delete** the plan + handoff — git history *is* the archive, so don't leave a merged-PR narrative
  behind. Abandoned branch → delete its docs. Accepted `research/` → becomes a plan, then `docs/`.
- **In-repo `docs/` carries NO verification banner.** It's git-tracked and canonical: git history is
  the record, updated in place alongside the code change (don't pin it to a commit hash). Cross-
  reference it from `CLAUDE.md` / `Server_PREREAD.md` by path.

## Handoffs

A Voice.Server handoff *is* generic-suite work — invoke the `handoff` skill (it writes to
`$AGENT_WORK_DIR/handoffs`). Layer these Voice specifics on its output: the `origin/master`
verification banner, and the `docs/`-graduation rule above. As always, broad multi-PR context belongs
in the `plan` doc, not the handoff — reference it by path.
