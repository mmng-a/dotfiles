#!/usr/bin/env python3
import argparse
import datetime as dt
import os
import re
import subprocess
import sys
from zoneinfo import ZoneInfo


def run_git(args, allow_failure=False):
    try:
        return subprocess.check_output(["git", *args], text=True, stderr=subprocess.STDOUT).strip()
    except subprocess.CalledProcessError as exc:
        if allow_failure:
            return ""
        print(exc.output, file=sys.stderr)
        raise SystemExit(exc.returncode)


def resolve_date(value, timezone):
    now = dt.datetime.now(timezone)
    if value:
        normalized = value.lower()
        if normalized in {"today", "今日"}:
            return now.date()
        if normalized in {"yesterday", "昨日"}:
            return now.date() - dt.timedelta(days=1)
        if normalized in {"day-before-yesterday", "おととい", "一昨日"}:
            return now.date() - dt.timedelta(days=2)
        return dt.date.fromisoformat(value)
    if 0 <= now.hour <= 4:
        return now.date() - dt.timedelta(days=1)
    return now.date()


def parse_commit_line(line):
    parts = line.split("\t", 4)
    if len(parts) != 5:
        return None
    commit_hash, author_name, author_iso, committer_iso, subject = parts
    return {
        "hash": commit_hash,
        "author": author_name,
        "author_iso": author_iso,
        "committer_iso": committer_iso,
        "subject": subject,
    }


def is_target_commit(commit, author, timezone, day):
    author_date = dt.datetime.fromisoformat(commit["author_iso"]).astimezone(timezone).date()
    if author_date != day:
        return False
    return not author or commit["author"] == author


def parse_pr_subject(subject):
    merge_match = re.match(r"Merge pull request #(\d+) from (.+)", subject)
    if merge_match:
        return {"number": merge_match.group(1), "source": merge_match.group(2), "kind": "merge"}
    squash_match = re.search(r"\(#(\d+)\)$", subject)
    if squash_match:
        return {"number": squash_match.group(1), "source": "", "kind": "squash"}
    return None


def get_parents(commit_hash):
    parents = run_git(["show", "-s", "--format=%P", commit_hash], allow_failure=True)
    return parents.split() if parents else []


def get_included_commits(commit_hash):
    parents = get_parents(commit_hash)
    if len(parents) < 2:
        return []
    output = run_git(
        [
            "log",
            "--reverse",
            "--no-merges",
            "--pretty=format:%h%x09%an%x09%aI%x09%s",
            f"{parents[0]}..{commit_hash}",
        ],
        allow_failure=True,
    )
    return output.splitlines() if output else []


def included_has_author_on_day(included, author, timezone, day):
    if not author:
        return True
    for line in included:
        parts = line.split("\t", 3)
        if len(parts) != 4:
            continue
        _, included_author, author_iso, _ = parts
        author_date = dt.datetime.fromisoformat(author_iso).astimezone(timezone).date()
        if included_author == author and author_date == day:
            return True
    return False


def filter_included_for_author_day(included, author, timezone, day):
    if not author:
        return included
    filtered = []
    for line in included:
        parts = line.split("\t", 3)
        if len(parts) != 4:
            continue
        _, included_author, author_iso, _ = parts
        author_date = dt.datetime.fromisoformat(author_iso).astimezone(timezone).date()
        if included_author == author and author_date == day:
            filtered.append(line)
    return filtered


def main():
    parser = argparse.ArgumentParser(description="Collect local git commits for a daily report.")
    parser.add_argument("--date", help="today, yesterday, day-before-yesterday, or YYYY-MM-DD")
    parser.add_argument("--timezone", default=os.environ.get("TZ", "Asia/Tokyo"))
    parser.add_argument("--author", help="Author name or email to filter by")
    parser.add_argument("--all-authors", action="store_true")
    parser.add_argument(
        "--pr-search-days",
        type=int,
        default=365,
        help="Days before and after the target date to scan for PR merge commits.",
    )
    args = parser.parse_args()

    timezone = ZoneInfo(args.timezone)
    day = resolve_date(args.date, timezone)
    start = dt.datetime.combine(day, dt.time.min, timezone)
    end = start + dt.timedelta(days=1)

    print(f"date: {day.isoformat()}")
    print(f"window: {start.isoformat()} to {end.isoformat()}")

    search_start = start - dt.timedelta(days=args.pr_search_days)
    search_end = end + dt.timedelta(days=args.pr_search_days)
    log_args = [
        f"--since={search_start.isoformat()}",
        f"--until={search_end.isoformat()}",
        "--date=iso-local",
        "--pretty=format:%h%x09%an%x09%aI%x09%cI%x09%s",
    ]

    author = args.author
    if not args.all_authors and not author:
        author = run_git(["config", "user.name"], allow_failure=True) or None
    print(f"author_filter: {author}" if author else "author_filter: none")

    output = run_git(["log", *log_args])
    if not output:
        print("commits: none")
        return

    all_commits = []
    for line in output.splitlines():
        commit = parse_commit_line(line)
        if commit:
            all_commits.append(commit)

    target_commits = [commit for commit in all_commits if is_target_commit(commit, author, timezone, day)]
    if not target_commits:
        print("commits: none")
        return

    pull_requests = []
    covered_hashes = set()
    ignored_pr_hashes = set()
    for commit in all_commits:
        pr = parse_pr_subject(commit["subject"])
        if not pr:
            continue
        included = get_included_commits(commit["hash"]) if pr["kind"] == "merge" else []
        if pr["source"].split("/")[-1] in {"develop", "main", "master"}:
            ignored_pr_hashes.add(commit["hash"])
            continue
        if pr["kind"] == "merge":
            if not included_has_author_on_day(included, author, timezone, day):
                ignored_pr_hashes.add(commit["hash"])
                continue
            visible_included = filter_included_for_author_day(included, author, timezone, day)
        else:
            if not is_target_commit(commit, author, timezone, day):
                continue
            visible_included = []
        included_hashes = [line.split("\t", 1)[0] for line in included]
        covered_hashes.add(commit["hash"])
        covered_hashes.update(included_hashes)
        pull_requests.append({
            "commit": commit,
            "pr": pr,
            "included": visible_included,
        })

    if pull_requests:
        print("\npull_requests:")
        for item in pull_requests:
            commit = item["commit"]
            pr = item["pr"]
            title = f"PR #{pr['number']}"
            if pr["source"]:
                title += f" from {pr['source']}"
            print(f"\n## {title} ({commit['hash']})")
            print(f"subject: {commit['subject']}")
            if item["included"]:
                print("included_commits:")
                for included in item["included"]:
                    print(f"- {included}")
            print("changed_files:")
            stats = run_git(["show", "--stat", "--oneline", "--no-renames", "--format=%h %s", commit["hash"]])
            print(stats)

    standalone = [
        commit
        for commit in target_commits
        if commit["hash"] not in covered_hashes and commit["hash"] not in ignored_pr_hashes
    ]
    if standalone:
        print("\nstandalone_commits:")
        for commit in standalone:
            print(
                f"{commit['hash']}\t{commit['author']}\tauthor:{commit['author_iso']}\t"
                f"commit:{commit['committer_iso']}\t{commit['subject']}"
            )

        print("\nstandalone_changed_files:")
    for commit in standalone:
        print(f"\n## {commit['hash']}")
        stats = run_git(["show", "--stat", "--oneline", "--no-renames", "--format=%h %s", commit["hash"]])
        print(stats)


if __name__ == "__main__":
    main()
