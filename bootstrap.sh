#!/usr/bin/env bash

# On coder devspaces, dotfiles is cloned to /home/coder/.config/coderv2/dotfiles
# output of execution is at ~/.dotfiles.log
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

osx_init() {
  brew bundle --file="$DOTFILES/extra/homebrew/Brewfile"
  brew cleanup
  set +e
  brew doctor
  set -e
}

linux_init() {
  sudo apt-get update
  xargs -a "$DOTFILES/extra/apt/packages.txt" sudo apt-get install -y
}

cargo_init() {
  local pkgs_file="$DOTFILES/extra/cargo/packages.txt"
  if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
  fi
  # Nothing to install if the list has no non-blank lines. This also avoids
  # invoking `cargo install` with zero args (which errors under `set -e`).
  grep -qE '[^[:space:]]' "$pkgs_file" 2>/dev/null || return 0
  # Feed crates on stdin: macOS (BSD) xargs has no GNU `-a/--arg-file` flag.
  grep -vE '^[[:space:]]*$' "$pkgs_file" | xargs cargo install
}

hammerspoon_spoons() {
  local spoons_dir="$DOTFILES/osx/.hammerspoon/Spoons"
  local urls_file="$DOTFILES/extra/hammerspoon/spoon-zip-urls"
  [[ ! -f "$urls_file" ]] && return 0
  mkdir -p "$spoons_dir"
  # handle no newline at the EOF case with `|| [ -n "$url" ]`
  while IFS= read -r url || [ -n "$url" ]; do
    echo "Installing spoon from $url"
    [[ -z "$url" ]] && continue
    local filename spoon_name
    filename="$(basename "$url")"
    spoon_name="${filename%.zip}"
    [[ -d "$spoons_dir/$spoon_name" ]] && continue
    curl -sSL -o "$spoons_dir/$filename" "$url"
    unzip -qo "$spoons_dir/$filename" -d "$spoons_dir/"
    rm "$spoons_dir/$filename"
  done <"$urls_file"
}

tpm_init() {
  command -v tmux &>/dev/null || return 0
  local plugins_dir="$HOME/.config/tmux/plugins"
  local tpm_dir="$plugins_dir/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi
  # install_plugins reads @tpm_plugins and TMUX_PLUGIN_MANAGER_PATH from a
  # running tmux server. A bare `start-server` neither sources our config nor
  # stays alive without a session, so bring up a throwaway detached session
  # (which sources ~/.tmux.conf) and keep it up across the install.
  tmux new-session -d -s tpm_bootstrap 2>/dev/null || true
  "$tpm_dir/bin/install_plugins" || true
  tmux kill-session -t tpm_bootstrap 2>/dev/null || true
}

setup_zsh_from_bash() {
  if command -v zsh &>/dev/null && [[ -f ~/.bashrc ]]; then
    if ! grep -q "exec /bin/zsh" ~/.bashrc; then
      printf '\nexport SHELL=/bin/zsh\nexec /bin/zsh -l\n' >>~/.bashrc
    fi
  fi
}

universal_dots() {
  if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
    mv ~/.zshrc ~/.zshrc.bak
  fi

  # The Homebrew installer writes a real ~/.zprofile (brew shellenv); back it up
  # so stow can link ours, which supersedes it.
  if [[ -f ~/.zprofile && ! -L ~/.zprofile ]]; then
    mv ~/.zprofile ~/.zprofile.bak
  fi

  # If .gitconfig exists and isn't already our symlink, preserve it as .gitconfig.local
  if [[ -f ~/.gitconfig && ! -L ~/.gitconfig ]]; then
    if [[ ! -f ~/.gitconfig.local ]]; then
      mv ~/.gitconfig ~/.gitconfig.local
    else
      rm ~/.gitconfig
    fi
  fi

  # Claude Code writes to ~/.claude/settings.json at runtime, so a real file
  # (not our symlink) will exist on first run; back it up so stow can link ours.
  if [[ -f ~/.claude/settings.json && ! -L ~/.claude/settings.json ]]; then
    mv ~/.claude/settings.json ~/.claude/settings.json.bak
  fi

  # ~/.claude/CLAUDE.md is a stub importing ~/.agents/AGENTS.md. Claude Code's
  # /memory command can create a real one; back it up so stow can link ours.
  if [[ -f ~/.claude/CLAUDE.md && ! -L ~/.claude/CLAUDE.md ]]; then
    mv ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
  fi

  # ~/agents/{AGENTS,CLAUDE}.md are versioned here (universal/agents) and stowed
  # into the otherwise-unversioned ~/agents workspace. They were real files
  # before that, and Unison had already replicated them to the other machine, so
  # a real file can exist on either side; back it up so stow can link ours.
  # Unison ignores both paths (osx/.unison/agents.prf) — each machine links its
  # own clone, so the dotfiles checkout need not sit at the same path on both.
  local agent_doc
  for agent_doc in AGENTS.md CLAUDE.md; do
    if [[ -f "$HOME/agents/$agent_doc" && ! -L "$HOME/agents/$agent_doc" ]]; then
      mv "$HOME/agents/$agent_doc" "$HOME/agents/$agent_doc.bak"
    fi
  done

  stow --restow --no-folding --ignore ".DS_Store" --target="$HOME" --dir="$DOTFILES" universal

  # Prune broken symlinks in ~/.claude/rules. Stow's unstow pass can only remove
  # links whose package file still exists, so deleting a rules/*.md from the repo
  # leaves a dangling link behind that Claude Code still tries to load. A broken
  # link here is useless regardless of who created it, and this dir (unlike
  # ~/.claude/skills) is not shared with the Roblox skill manager.
  # `if` (not `cond && rm`) so a false test on the last iteration does not make
  # the loop — and the function — exit non-zero under `set -e`.
  local rule
  for rule in "$HOME"/.claude/rules/*; do
    if [[ -L "$rule" && ! -e "$rule" ]]; then
      rm "$rule"
    fi
  done
}

# Agent-agnostic skills live under universal/.agents/skills. Codex (and the
# Roblox skill manager's own entries under ~/.claude/skills) only discover a
# skill when its directory is itself a symlink — a real dir containing a
# symlinked SKILL.md is ignored. So we fold at the skill-dir level: stowing the
# `skills` package with folding enabled makes ~/.agents/skills/<skill> and
# ~/.claude/skills/<skill> each a single directory symlink into the dotfiles
# tree. `universal` ignores `.agents` (see universal/.stow-local-ignore) so all
# ~/.agents handling lives here.
#
# ~/.claude/skills is shared with the Roblox skill manager, so it stays a real
# dir; folding only our skill entries leaves the manager's symlinks alone.
# AGENTS.md is linked into ~/.agents only (Codex reads ~/.agents; Claude reads
# ~/.claude/skills).
agents_dots() {
  local agents_src="$DOTFILES/universal/.agents"
  local skill target

  # One-time migration off the old --no-folding layout, which left our entries
  # as real dirs (with a symlinked SKILL.md). A pre-existing real dir blocks
  # folding, so remove OUR entries (never the manager's symlinks) when they are
  # not already symlinks.
  for target in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
    mkdir -p "$target"
    for skill in "$agents_src/skills"/*/; do
      skill="$(basename "$skill")"
      if [[ -d "$target/$skill" && ! -L "$target/$skill" ]]; then
        rm -rf "${target:?}/$skill"
      fi
    done
  done

  # AGENTS.md → ~/.agents/AGENTS.md; keep ~/.agents a real dir (link the file
  # only), and leave the skills subtree to the folding passes below.
  stow --restow --no-folding --ignore ".DS_Store" --ignore "skills" \
    --target="$HOME/.agents" --dir="$DOTFILES/universal" .agents

  # Fold each skill into a directory symlink in both shared targets.
  stow --restow --ignore ".DS_Store" --target="$HOME/.agents/skills" --dir="$agents_src" skills
  stow --restow --ignore ".DS_Store" --target="$HOME/.claude/skills" --dir="$agents_src" skills
}

# ~/vault's hidden .claude/ (slash commands) isn't carried by Obsidian Sync, so
# stow it from git for durability. Guarded on ~/vault so non-vault machines skip.
vault_dots() {
  [[ -d "$HOME/vault" ]] || return 0
  stow --restow --no-folding --ignore ".DS_Store" --target="$HOME/vault" --dir="$DOTFILES" vault
}

# Link ~/agents doc-kinds into the Obsidian vault so they are indexed and
# phone-portable, while ~/agents stays the real $AGENT_WORK_DIR root. Context
# picks the vault subtree; vault-absent machines skip and keep real dirs.
agents_workspace_links() {
  [[ -d "$HOME/vault" ]] || return 0

  # Context override wins; otherwise derive from this clone's origin host.
  local context="${AGENT_CONTEXT:-}"
  if [[ -z "$context" ]]; then
    local origin
    origin="$(git -C "$DOTFILES" remote get-url origin 2>/dev/null || true)"
    case "$origin" in
    *github.rbx.com*) context="Work" ;;
    *github.com*) context="Personal" ;;
    *)
      echo "agents_workspace_links: cannot derive context from '$origin';" \
        "set AGENT_CONTEXT=Work|Personal. Skipping." >&2
      return 0
      ;;
    esac
  fi

  case "$context" in
  [Ww]ork) context="Work" ;;
  [Pp]ersonal) context="Personal" ;;
  *)
    echo "agents_workspace_links: invalid AGENT_CONTEXT '$context'." >&2
    return 0
    ;;
  esac

  local base="$HOME/vault/10 - Agents/$context"
  mkdir -p "$HOME/agents"

  local kind src link
  for kind in Research Plans Handoffs Reviews Archives Prompts; do
    src="$base/$kind"
    link="$HOME/agents/$(echo "$kind" | tr '[:upper:]' '[:lower:]')"

    # Skip loudly if the vault lacks the target dir.
    if [[ ! -d "$src" ]]; then
      echo "agents_workspace_links: missing vault dir '$src'; skipping." >&2
      continue
    fi

    # A real path here means bytes still live outside the vault; do not
    # clobber them. Only (re)link when absent or already a symlink.
    if [[ -L "$link" ]]; then
      ln -sfn "$src" "$link"
    elif [[ ! -e "$link" ]]; then
      ln -s "$src" "$link"
    else
      echo "agents_workspace_links: '$link' is a real path; not linking." \
        "Move its contents into '$src' first." >&2
    fi
  done
}

osx_dots() {
  stow --restow --no-folding --ignore ".DS_Store" --target="$HOME" --dir="$DOTFILES" osx
}

linux_dots() {
  stow --restow --no-folding --ignore ".DS_Store" --target="$HOME" --dir="$DOTFILES" linux
}

rblx_dots() {
  if [[ -d "$DOTFILES/rblx" ]]; then
    stow --restow --no-folding --ignore ".DS_Store" --target="$HOME" --dir="$DOTFILES" rblx
  fi
}

rblx_init() {
  if [[ -f "$DOTFILES/extra/rblx/setup.sh" ]]; then
    # shellcheck disable=SC1091
    source "$DOTFILES/extra/rblx/setup.sh"
  fi
}

# Install + load the agent-sync LaunchAgent (macOS). The plist is copied (not
# stowed) because launchd refuses to load symlinked plists and ~/Library is
# TCC-protected. bootout-then-bootstrap makes this idempotent across re-runs.
agent_sync_init() {
  local src="$DOTFILES/extra/launchd/com.aciarlillo.agent-sync.plist"
  local dst="$HOME/Library/LaunchAgents/com.aciarlillo.agent-sync.plist"
  [[ -f "$src" ]] || return 0
  mkdir -p "$HOME/Library/LaunchAgents"
  cp "$src" "$dst"
  local domain="gui/$(id -u)"
  launchctl bootout "$domain/com.aciarlillo.agent-sync" 2>/dev/null || true
  launchctl bootstrap "$domain" "$dst"
}

main() {
  local uname_s
  uname_s="$(uname -s)"
  case "$uname_s" in
  Darwin)
    [[ "${1:-}" != "dots" ]] && osx_init
    [[ "${1:-}" != "dots" ]] && cargo_init
    [[ "${1:-}" != "dots" ]] && rblx_init
    [[ "${1:-}" != "dots" ]] && hammerspoon_spoons
    universal_dots
    vault_dots
    agents_workspace_links
    agents_dots
    [[ "${1:-}" != "dots" ]] && tpm_init
    osx_dots
    [[ "${1:-}" != "dots" ]] && agent_sync_init
    rblx_dots
    ;;
  Linux)
    [[ "${1:-}" != "dots" ]] && linux_init
    [[ "${1:-}" != "dots" ]] && cargo_init
    [[ "${1:-}" != "dots" ]] && rblx_init
    setup_zsh_from_bash
    universal_dots
    vault_dots
    agents_workspace_links
    agents_dots
    [[ "${1:-}" != "dots" ]] && tpm_init
    linux_dots
    rblx_dots
    ;;
  *)
    echo "Unsupported OS: $uname_s" >&2
    exit 1
    ;;
  esac
  echo ""
  echo "Bootstrap complete for $uname_s"
}

# Allow sourcing for tests without executing; run only when invoked directly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
