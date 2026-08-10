#!/usr/bin/env python3
"""Collect Git evidence for drafting iOS App Store release notes."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def run_git(repo: Path, args: list[str], allow_fail: bool = False) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=repo,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        if allow_fail:
            return ""
        message = result.stderr.strip() or result.stdout.strip()
        raise SystemExit(f"git {' '.join(args)} failed: {message}")
    return result.stdout.strip()


def find_latest_tag(repo: Path) -> str:
    tag = run_git(repo, ["describe", "--tags", "--abbrev=0"], allow_fail=True)
    return tag.strip()


def find_previous_tag(repo: Path) -> str:
    tag = run_git(repo, ["describe", "--tags", "--abbrev=0", "HEAD^"], allow_fail=True)
    return tag.strip()


def empty_tree(repo: Path) -> str:
    return run_git(repo, ["hash-object", "-t", "tree", "/dev/null"])


def validate_explicit_range(repo: Path, rev_range: str) -> None:
    run_git(repo, ["rev-list", "--max-count=1", rev_range])


def validate_ref(repo: Path, ref: str) -> None:
    run_git(repo, ["rev-parse", "--verify", f"{ref}^{{commit}}"])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Collect latest-tag-to-HEAD Git context for release notes."
    )
    parser.add_argument("repo", help="Path to the Git repository")
    parser.add_argument("--from", dest="from_ref", help="Start ref or tag")
    parser.add_argument("--range", dest="rev_range", help="Explicit Git rev range")
    parser.add_argument("--max-commits", type=int, default=160)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    repo = Path(args.repo).expanduser().resolve()
    if not repo.exists():
        raise SystemExit(f"Repository path does not exist: {repo}")

    inside = run_git(repo, ["rev-parse", "--is-inside-work-tree"], allow_fail=True)
    if inside != "true":
        raise SystemExit(f"Not a Git repository: {repo}")

    branch = run_git(repo, ["branch", "--show-current"], allow_fail=True) or "(detached)"
    head = run_git(repo, ["rev-parse", "--short", "HEAD"])
    head_tags = run_git(repo, ["tag", "--points-at", "HEAD"], allow_fail=True)
    boundary_note = ""

    if args.rev_range:
        validate_explicit_range(repo, args.rev_range)
        latest_tag = args.from_ref or "(explicit range)"
        rev_range = args.rev_range
        diff_args = [rev_range]
    else:
        latest_tag = args.from_ref or find_latest_tag(repo)
        if args.from_ref:
            validate_ref(repo, args.from_ref)
        elif latest_tag and latest_tag in head_tags.splitlines():
            previous_tag = find_previous_tag(repo)
            if previous_tag:
                boundary_note = (
                    f"HEAD is tagged with {latest_tag}; using previous tag "
                    f"{previous_tag} as the release boundary."
                )
                latest_tag = previous_tag

        if latest_tag:
            rev_range = f"{latest_tag}..HEAD"
            diff_args = [rev_range]
        else:
            rev_range = "HEAD"
            diff_args = [empty_tree(repo), "HEAD"]
            boundary_note = "No reachable tag found; diff uses the empty tree to cover all history."

    commits = run_git(
        repo,
        [
            "log",
            rev_range,
            f"--max-count={args.max_commits}",
            "--date=short",
            "--pretty=format:%h%x09%ad%x09%s",
        ],
        allow_fail=True,
    )
    changed_files = run_git(
        repo,
        ["diff", "--name-status", *diff_args],
    )
    stat = run_git(repo, ["diff", "--stat", *diff_args])

    print("# Release Context")
    print()
    print(f"repo: {repo}")
    print(f"branch: {branch}")
    print(f"head: {head}")
    print(f"latest_tag: {latest_tag or '(none found)'}")
    print(f"range: {rev_range}")
    if head_tags:
        print(f"head_tags: {head_tags.replace(chr(10), ', ')}")
    if boundary_note:
        print(f"boundary_note: {boundary_note}")
    print()
    print("## Commits")
    print(commits or "(no commits in range)")
    print()
    print("## Changed Files")
    print(changed_files or "(no changed files in range)")
    print()
    print("## Diff Stat")
    print(stat or "(no diff stat)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
