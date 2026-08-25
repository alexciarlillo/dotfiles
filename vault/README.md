# vault

Stow package for the Obsidian vault at `~/vault`. `bootstrap.sh` stows this into
`~/vault` (see `vault_dots`), so the vault's hidden `.claude/` — which Obsidian
Sync does **not** carry — is git-backed and restored on any new machine.

Only `.claude/` is stowed. Vault *content* (notes, `CLAUDE.md`, attachments) is
managed by Obsidian Sync and is intentionally **not** in this repo. This README
is excluded from stow via `.stow-local-ignore`.

## Layout

```
vault/
└── .claude/
    └── commands/     # slash commands → ~/vault/.claude/commands/
```

## Notes

- New machine: clone dotfiles, create/sync `~/vault`, run `./bootstrap.sh`.
- `vault_dots` is guarded on `~/vault` existing, so devspaces/servers skip it.
- Add a new command by dropping a `.md` here and re-running `./bootstrap.sh`.
