#!/usr/bin/env python3
"""Discover and prepare direct GitHub Enterprise review requests."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit, urlunsplit


PR_URL_RE = re.compile(r"https?://[^/\s]+/[^/\s]+/[^/\s]+/pull/\d+")
REVIEWED_HEAD_RE = re.compile(
    r"(?:reviewed\s+head|pr\s+tip|last\s+verified)[^\n]*?"
    r"([0-9a-f]{40})",
    re.IGNORECASE,
)


def run_json(command: list[str], host: str) -> Any:
    env = os.environ.copy()
    env["GH_HOST"] = host
    result = subprocess.run(
        command, check=False, capture_output=True, text=True, env=env
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or "command failed: " + " ".join(command))
    return json.loads(result.stdout)


def canonical_url(raw_url: str) -> str:
    parts = urlsplit(raw_url.rstrip("/"))
    return urlunsplit((parts.scheme.lower(), parts.netloc.lower(), parts.path, "", ""))


def index_review_documents(directory: Path) -> dict[str, list[dict[str, Any]]]:
    index: dict[str, list[dict[str, Any]]] = {}
    if not directory.is_dir():
        return index
    for path in sorted(directory.glob("*.md")):
        text = path.read_text(encoding="utf-8", errors="replace")
        urls = {canonical_url(value) for value in PR_URL_RE.findall(text)}
        shas = sorted({value.lower() for value in REVIEWED_HEAD_RE.findall(text)})
        for url in urls:
            index.setdefault(url, []).append({"path": str(path), "shas": shas})
    return index


def parse_repo_mapping(values: list[str]) -> dict[str, Path]:
    mappings: dict[str, Path] = {}
    for value in values:
        if "=" not in value:
            raise ValueError(f"invalid --repo value: {value!r}; expected OWNER/REPO=PATH")
        name, raw_path = value.split("=", 1)
        path = Path(raw_path).expanduser().resolve()
        if not name or not path.is_dir():
            raise ValueError(f"invalid repository mapping: {value!r}")
        mappings[name.lower()] = path
    return mappings


def fetch_refs(entry: dict[str, Any], repo_path: Path, host: str) -> dict[str, Any]:
    owner_repo = entry["repository"]
    number = entry["number"]
    prefix = f"refs/review-requests/{owner_repo.replace('/', '-')}/{number}"
    head_ref = f"{prefix}/head"
    base_ref = f"{prefix}/base"
    remote_url = f"https://{host}/{owner_repo}.git"
    command = [
        "git", "-C", str(repo_path), "fetch", "--no-tags", remote_url,
        f"+refs/pull/{number}/head:{head_ref}",
        f"+refs/heads/{entry['base_ref_name']}:{base_ref}",
    ]
    result = subprocess.run(command, check=False, capture_output=True, text=True)
    fetch = {
        "repo_path": str(repo_path),
        "head_ref": head_ref,
        "base_ref": base_ref,
        "ok": result.returncode == 0,
    }
    if result.returncode:
        fetch["error"] = result.stderr.strip() or result.stdout.strip()
    return fetch


def discover(args: argparse.Namespace) -> dict[str, Any]:
    candidates = run_json(
        [
            "gh", "search", "prs", "--review-requested", args.user,
            "--state", "open", "--limit", str(args.limit),
            "--json", "url,repository,number,title,updatedAt,author",
        ],
        args.host,
    )
    documents = index_review_documents(args.reviews_dir)
    mappings = parse_repo_mapping(args.repo)
    entries: list[dict[str, Any]] = []
    team_only: list[dict[str, Any]] = []

    for candidate in candidates:
        details = run_json(
            [
                "gh", "pr", "view", candidate["url"], "--json",
                "url,headRefOid,baseRefOid,headRefName,baseRefName,"
                "reviewRequests,isDraft,state,title,author",
            ],
            args.host,
        )
        direct = any(
            request.get("__typename") == "User"
            and request.get("login", "").casefold() == args.user.casefold()
            for request in details.get("reviewRequests", [])
        )
        if not direct:
            team_only.append({
                "url": canonical_url(details["url"]),
                "repository": candidate["repository"]["nameWithOwner"],
                "number": candidate["number"],
            })
            continue

        url = canonical_url(details["url"])
        head_sha = details["headRefOid"].lower()
        matches = documents.get(url, [])
        exact = next((doc for doc in matches if head_sha in doc["shas"]), None)
        if exact:
            status = "already_reviewed"
            existing = exact["path"]
            previous_sha = head_sha
        elif matches:
            status = "head_changed"
            existing = matches[0]["path"]
            previous_sha = matches[0]["shas"][0] if matches[0]["shas"] else None
        else:
            status = "needs_review"
            existing = None
            previous_sha = None

        entry: dict[str, Any] = {
            "status": status,
            "url": url,
            "repository": candidate["repository"]["nameWithOwner"],
            "number": candidate["number"],
            "title": details["title"],
            "author": details["author"]["login"],
            "is_draft": details["isDraft"],
            "head_sha": head_sha,
            "head_ref_name": details["headRefName"],
            "base_sha": details["baseRefOid"].lower(),
            "base_ref_name": details["baseRefName"],
            "existing_document": existing,
            "previous_head_sha": previous_sha,
        }
        if args.fetch and status != "already_reviewed":
            repo_path = mappings.get(entry["repository"].lower())
            entry["fetch"] = (
                fetch_refs(entry, repo_path, args.host)
                if repo_path
                else {"ok": False, "error": "no --repo mapping supplied"}
            )
        entries.append(entry)

    counts = {name: sum(item["status"] == name for item in entries) for name in (
        "needs_review", "head_changed", "already_reviewed"
    )}
    return {
        "schema_version": 1,
        "host": args.host,
        "reviewer": args.user,
        "deduplication_key": ["url", "head_sha"],
        "counts": counts,
        "pull_requests": entries,
        "excluded_team_only": team_only,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--user", required=True, help="individual reviewer login")
    parser.add_argument("--host", default=os.environ.get("GH_HOST", "github.rbx.com"))
    parser.add_argument("--reviews-dir", type=Path, default=Path("~/agents/reviews").expanduser())
    parser.add_argument("--limit", type=int, default=1000)
    parser.add_argument("--repo", action="append", default=[], metavar="OWNER/REPO=PATH")
    parser.add_argument("--fetch", action="store_true", help="fetch refs for non-skipped PRs")
    parser.add_argument("--output", type=Path, help="write JSON manifest to this path")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        manifest = discover(args)
    except (OSError, RuntimeError, ValueError, json.JSONDecodeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1
    rendered = json.dumps(manifest, indent=2) + "\n"
    if args.output:
        args.output.expanduser().write_text(rendered, encoding="utf-8")
    else:
        sys.stdout.write(rendered)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
