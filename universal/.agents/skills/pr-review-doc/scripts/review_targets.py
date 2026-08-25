#!/usr/bin/env python3
"""Resolve GitHub Enterprise pull requests into review targets.

Two entry points onto one resolver: `--user` searches the direct review-request
queue, `--pr` names pull requests explicitly. Both emit the same manifest, so a
queue sweep and a one-off review deduplicate identically.

Read-only against GitHub. Every call is a GET (`gh search prs`, `gh pr view`,
`gh api ... /reviews`, `gh api user`); the only writes are local git refs under
`refs/review-requests/`, and only with `--fetch`.
"""

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


SCHEMA_VERSION = 5
STATUSES = ("needs_review", "head_changed", "already_reviewed", "unresolved")

PR_URL_RE = re.compile(r"https?://[^/\s]+/[^/\s]+/[^/\s]+/pull/\d+")
PR_PATH_RE = re.compile(r"^/([^/]+)/([^/]+)/pull/(\d+)$")
# `--pr` shorthand for a PR on --host: OWNER/REPO#123 or OWNER/REPO/123.
PR_SHORTHAND_RE = re.compile(r"^([^/\s]+)/([^/#\s]+)[#/](\d+)$")
SHA_RE = re.compile(r"\b[0-9a-f]{40}\b", re.IGNORECASE)
# YAML frontmatter only counts when it opens the file; a bare `---` further down
# is a horizontal rule.
FRONTMATTER_RE = re.compile(r"\A---[ \t]*\r?\n(.*?)^---[ \t]*$", re.DOTALL | re.MULTILINE)
FRONTMATTER_VERIFIED_RE = re.compile(
    r"^[ \t]*verified_against[ \t]*:(.*)$",
    re.IGNORECASE | re.MULTILINE,
)
# Legacy: the bold metadata block that preceded frontmatter.
VERIFIED_AGAINST_RE = re.compile(
    r"^[ \t]*\*\*verified\s+against:\*\*(.*)$",
    re.IGNORECASE | re.MULTILINE,
)
# Legacy: before the field split, the date and the ref shared one line.
LEGACY_HEAD_RE = re.compile(
    r"(?:reviewed\s+head|pr\s+tip|last\s+verified)[^\n]*?"
    r"([0-9a-f]{40})",
    re.IGNORECASE,
)

RESOLUTION_ERRORS = (OSError, RuntimeError, ValueError, KeyError, TypeError, json.JSONDecodeError)
UNKNOWN_REVIEW_FIELDS = {
    "reviewed_by_user": None,
    "has_user_review": None,
    "user_review_head_sha": None,
    "user_review_state": None,
    "user_review_submitted_at": None,
}


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
    parts = urlsplit(raw_url)
    return urlunsplit(
        (parts.scheme.lower(), parts.netloc.lower(), parts.path.rstrip("/"), "", "")
    )


def url_key(canonical: str) -> str:
    """Dedup key for a canonical URL. GitHub paths are case-insensitive; display case isn't."""
    return canonical.casefold()


def dedupe_lower(values: list[str]) -> list[str]:
    seen: dict[str, None] = {}
    for value in values:
        seen.setdefault(value.lower(), None)
    return list(seen)


def shas_in(lines: list[str]) -> list[str]:
    values: list[str] = []
    for line in lines:
        values.extend(SHA_RE.findall(line))
    return values


def document_metadata(text: str) -> tuple[list[str], str | None]:
    """Reviewed SHAs (in order of appearance) and which format they came from.

    Frontmatter is authoritative; the two legacy forms keep working so documents
    written before each change still deduplicate.
    """
    frontmatter = FRONTMATTER_RE.match(text)
    if frontmatter:
        values = shas_in(FRONTMATTER_VERIFIED_RE.findall(frontmatter.group(1)))
        if values:
            return dedupe_lower(values), "frontmatter"
    values = shas_in(VERIFIED_AGAINST_RE.findall(text))
    if values:
        return dedupe_lower(values), "legacy-field"
    values = LEGACY_HEAD_RE.findall(text)
    if values:
        return dedupe_lower(values), "legacy-prose"
    return [], None


def document_shas(text: str) -> list[str]:
    return document_metadata(text)[0]


def index_review_documents(directory: Path) -> dict[str, list[dict[str, Any]]]:
    """Documents by `url_key`, each carrying its path, reviewed SHAs, format, and canonical URL."""
    index: dict[str, list[dict[str, Any]]] = {}
    if not directory.is_dir():
        return index
    for path in sorted(directory.glob("*.md")):
        text = path.read_text(encoding="utf-8", errors="replace")
        urls = {canonical_url(value) for value in PR_URL_RE.findall(text)}
        shas, doc_format = document_metadata(text)
        for url in urls:
            index.setdefault(url_key(url), []).append(
                {"path": str(path), "shas": shas, "format": doc_format, "url": url}
            )
    return index


def split_pr_url(url: str, host: str) -> tuple[str, int] | None:
    """`(OWNER/REPO, number)` for a PR URL on `host`, else None."""
    parts = urlsplit(url)
    if parts.netloc.lower() != host.lower():
        return None
    match = PR_PATH_RE.match(parts.path)
    if not match:
        return None
    return f"{match.group(1)}/{match.group(2)}", int(match.group(3))


def parse_pr_target(value: str, host: str) -> str:
    """Canonical PR URL for a `--pr` value: a full URL or `OWNER/REPO#NUMBER`."""
    value = value.strip()
    if "://" in value:
        url = canonical_url(value)
        if split_pr_url(url, host) is None:
            raise ValueError(f"--pr {value!r} is not a pull request URL on {host}")
        return url
    match = PR_SHORTHAND_RE.match(value)
    if not match:
        raise ValueError(f"invalid --pr value: {value!r}; expected a PR URL or OWNER/REPO#NUMBER")
    owner, repo, number = match.groups()
    return canonical_url(f"https://{host}/{owner}/{repo}/pull/{number}")


def authenticated_login(host: str) -> str:
    """The login `gh` is authenticated as, so `--user` is optional for one-off reviews."""
    login = (run_json(["gh", "api", "user"], host) or {}).get("login")
    if not login:
        raise RuntimeError("could not determine the authenticated login; pass --user")
    return login


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


def latest_user_review(repository: str, number: int, user: str, host: str) -> dict[str, Any] | None:
    """The user's most recent *submitted* review, across all pages. Pending ones don't count."""
    pages = run_json(
        [
            "gh", "api", "--paginate", "--slurp",
            f"repos/{repository}/pulls/{number}/reviews?per_page=100",
        ],
        host,
    )
    reviews: list[dict[str, Any]] = []
    for page in pages if isinstance(pages, list) else [pages]:
        if isinstance(page, list):
            reviews.extend(item for item in page if isinstance(item, dict))
        elif isinstance(page, dict):
            reviews.append(page)
    mine = [
        review for review in reviews
        if (review.get("user") or {}).get("login", "").casefold() == user.casefold()
        and review.get("submitted_at")
    ]
    if not mine:
        return None
    return max(mine, key=lambda review: (review["submitted_at"], review.get("id") or 0))


def approval_count(details: dict[str, Any]) -> int:
    """How many reviewers currently stand as approving.

    `latestReviews` is already one entry per reviewer, so a later COMMENTED
    review does not displace that reviewer's earlier approval, and a dismissed
    approval no longer reads as APPROVED.
    """
    return sum(
        1
        for review in details.get("latestReviews") or []
        if isinstance(review, dict) and (review.get("state") or "").upper() == "APPROVED"
    )


def review_fields(
    repository: str, number: int, user: str, host: str, head_sha: str, in_review_queue: bool
) -> dict[str, Any]:
    """`reviewed_by_user` is true only at the current head, undismissed, and not re-requested."""
    latest = latest_user_review(repository, number, user, host)
    if latest is None:
        return dict(UNKNOWN_REVIEW_FIELDS, has_user_review=False, reviewed_by_user=False)
    review_head = (latest.get("commit_id") or "").lower()
    state = (latest.get("state") or "").upper()
    return {
        "reviewed_by_user": (
            review_head == head_sha and state != "DISMISSED" and not in_review_queue
        ),
        "has_user_review": True,
        "user_review_head_sha": review_head or None,
        "user_review_state": state or None,
        "user_review_submitted_at": latest.get("submitted_at"),
    }


def build_targets(
    candidates: list[dict[str, Any]],
    requested: list[str],
    documents: dict[str, list[dict[str, Any]]],
    host: str,
) -> dict[str, dict[str, Any]]:
    """Explicit `--pr` targets, else the review-request queue ∪ the PRs docs already track.

    In queue mode, submitting a review drops us from the queue, so a queue-only work
    set could never flip a document to reviewed — hence the union. Explicit mode skips
    that union: naming one PR should resolve one PR, not every documented PR.
    """
    targets: dict[str, dict[str, Any]] = {}
    for url in requested:
        repository, number = split_pr_url(url, host)  # validated by parse_pr_target
        targets[url_key(url)] = {
            "url": url,
            "from_queue": False,
            "requested": True,
            "repository": repository,
            "number": number,
        }
    if requested:
        return targets
    for candidate in candidates:
        url = canonical_url(candidate["url"])
        targets[url_key(url)] = {
            "url": url,
            "from_queue": True,
            "requested": False,
            "repository": candidate["repository"]["nameWithOwner"],
            "number": candidate["number"],
        }
    for key, matches in documents.items():
        if key in targets:
            continue
        url = matches[0]["url"]
        split = split_pr_url(url, host)
        if split is None:
            continue
        targets[key] = {
            "url": url,
            "from_queue": False,
            "requested": False,
            "repository": split[0],
            "number": split[1],
        }
    return targets


def classify(
    head_sha: str, matches: list[dict[str, Any]]
) -> tuple[str, dict[str, Any] | None, str | None]:
    """Status, the matched document (if any), and the head it recorded."""
    exact = next((doc for doc in matches if head_sha in doc["shas"]), None)
    if exact:
        return "already_reviewed", exact, head_sha
    if matches:
        shas = matches[0]["shas"]
        return "head_changed", matches[0], shas[0] if shas else None
    return "needs_review", None, None


def discover(args: argparse.Namespace) -> dict[str, Any]:
    mappings = parse_repo_mapping(args.repo)
    requested = [parse_pr_target(value, args.host) for value in args.pr]
    user = args.user or authenticated_login(args.host)
    candidates: list[dict[str, Any]] = []
    if not requested:
        # A failed queue search leaves the discovery set unknown, so it fails the run.
        candidates = run_json(
            [
                "gh", "search", "prs", "--review-requested", user,
                "--state", "open", "--limit", str(args.limit),
                "--json", "url,repository,number,title,updatedAt,author",
            ],
            args.host,
        )
    documents = index_review_documents(args.reviews_dir)
    targets = build_targets(candidates, requested, documents, args.host)
    entries: list[dict[str, Any]] = []
    team_only: list[dict[str, Any]] = []

    for key, target in targets.items():
        url = target["url"]
        matches = documents.get(key, [])
        try:
            details = run_json(
                [
                    "gh", "pr", "view", url, "--json",
                    "url,headRefOid,baseRefOid,headRefName,baseRefName,"
                    "reviewRequests,latestReviews,isDraft,state,title,author",
                ],
                args.host,
            )
        except RESOLUTION_ERRORS as error:
            entries.append({
                "status": "unresolved",
                "url": url,
                "requested": target["requested"],
                "repository": target["repository"],
                "number": target["number"],
                "pr_state": None,
                "in_review_queue": None,
                "approvals": None,
                "existing_document": matches[0]["path"] if matches else None,
                "existing_document_format": matches[0]["format"] if matches else None,
                "resolution_error": str(error),
                **UNKNOWN_REVIEW_FIELDS,
            })
            continue

        # GitHub's own casing wins over whatever a document happened to record.
        url = canonical_url(details["url"])
        in_review_queue = any(
            request.get("__typename") == "User"
            and request.get("login", "").casefold() == user.casefold()
            for request in details.get("reviewRequests", [])
        )
        # A team-only request we have never documented isn't ours to review; one we
        # already track stays in the work set so its document keeps being maintained.
        # An explicit `--pr` target is never excluded — it was asked for by name.
        if target["from_queue"] and not in_review_queue and not matches:
            team_only.append({
                "url": url,
                "repository": target["repository"],
                "number": target["number"],
            })
            continue

        head_sha = details["headRefOid"].lower()
        status, existing, previous_sha = classify(head_sha, matches)
        pr_state = (details.get("state") or "").lower() or None
        entry: dict[str, Any] = {
            "status": status,
            "url": url,
            "requested": target["requested"],
            "repository": target["repository"],
            "number": target["number"],
            "title": details["title"],
            "author": (details.get("author") or {}).get("login"),
            "is_draft": details["isDraft"],
            "pr_state": pr_state,
            "in_review_queue": in_review_queue,
            "approvals": approval_count(details),
            "head_sha": head_sha,
            "head_ref_name": details["headRefName"],
            "base_sha": details["baseRefOid"].lower(),
            "base_ref_name": details["baseRefName"],
            "existing_document": existing["path"] if existing else None,
            "existing_document_format": existing["format"] if existing else None,
            "previous_head_sha": previous_sha,
        }
        try:
            entry.update(
                review_fields(
                    target["repository"], target["number"], user, args.host,
                    head_sha, in_review_queue,
                )
            )
        except RESOLUTION_ERRORS as error:
            entry.update(UNKNOWN_REVIEW_FIELDS)
            entry["resolution_error"] = str(error)

        # In queue mode refs are only worth fetching for an open PR still owing a
        # pass. An explicit target is fetched regardless: re-reviewing a head we
        # already documented, or reading a merged PR after the fact, are both valid.
        wanted = target["requested"] or (status != "already_reviewed" and pr_state == "open")
        if args.fetch and wanted:
            repo_path = mappings.get(entry["repository"].lower())
            entry["fetch"] = (
                fetch_refs(entry, repo_path, args.host)
                if repo_path
                else {"ok": False, "error": "no --repo mapping supplied"}
            )
        entries.append(entry)

    counts = {name: sum(item["status"] == name for item in entries) for name in STATUSES}
    return {
        "schema_version": SCHEMA_VERSION,
        "host": args.host,
        "mode": "explicit" if requested else "queue",
        "reviewer": user,
        "deduplication_key": ["url", "head_sha"],
        "counts": counts,
        "pull_requests": entries,
        "excluded_team_only": team_only,
    }


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--pr", action="append", default=[], metavar="URL|OWNER/REPO#N",
        help="resolve these PRs instead of searching the review queue (repeatable)",
    )
    parser.add_argument(
        "--user", help="reviewer login; defaults to the authenticated `gh` user"
    )
    parser.add_argument("--host", default=os.environ.get("GH_HOST", "github.rbx.com"))
    parser.add_argument("--reviews-dir", type=Path, default=Path("~/agents/reviews").expanduser())
    parser.add_argument("--limit", type=int, default=1000, help="queue-mode search cap")
    parser.add_argument("--repo", action="append", default=[], metavar="OWNER/REPO=PATH")
    parser.add_argument(
        "--fetch", action="store_true",
        help="fetch head/base refs: every --pr target, or the open queue PRs still owing a pass",
    )
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
