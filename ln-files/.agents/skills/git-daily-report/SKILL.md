---
name: git-daily-report
description: Create concise Japanese daily report bullets from local Git history, preferring PR-sized work units over individual commits. Use when the user asks for 日報, daily report, work summary, PR summary, commit summary, or wants a report for a specified date such as 今日, 昨日, おととい, 5/23, or YYYY-MM-DD based on Git history.
---

# Git Daily Report

## Workflow

1. Resolve the target date in the user's locale/timezone.
   - If the user specifies a date, use that exact calendar date.
   - If no date is specified, use today.
   - If no date is specified and local time is between 00:00 and 04:59, use the previous day.
   - Treat the report window as `00:00:00` inclusive to next-day `00:00:00` exclusive.
2. Inspect local Git history for the current repository.
   - Prefer commits authored by the user. Start with `git config user.name`; if that misses obvious user commits, inspect all authors for the day and choose the user's known author name.
   - Exclude other authors unless the user asks for team-wide work.
   - Do not include uncommitted changes unless explicitly requested.
3. Use `scripts/collect_git_day.py` to gather PR-sized units first.
   - Treat `Merge pull request #...` commits as primary report units.
   - Treat squash-merge subjects ending in `(#123)` as PR units when the local squash commit itself matches the target date/author.
   - Prefer PRs that contain the user's commits authored on the target date.
   - Ignore broad integration PRs from `develop`, `main`, or `master` unless the user asks about merged/integrated work.
   - Ignore PRs made only of other authors' commits unless the user asks for team-wide work or merge work.
   - Do not separately summarize commits already included in a PR unit.
   - Use `standalone_commits` only for work that is not covered by a PR unit.
   - Local Git cannot always recover original commits behind squash merges by another author/date. If `standalone_commits` look like PR work and GitHub metadata is available, use `gh` or the GitHub connector to identify the PR before summarizing.
4. Summarize into short Japanese bullet points.

## Output Style

Use the compact style the user prefers:

```markdown
**日報案**
- 管理画面の更新処理まわりを修正。
- 日付入力の扱いを改善。
- フォームのバリデーション表示を改善。
- 管理モーダルと一覧UIを調整。
- 出欠イベントを日付順に表示。
- ニュースレターPDF表示を改善。
```

Guidelines:

- Keep each bullet short: usually 15-28 Japanese characters, one sentence.
- Use 5-10 bullets for a normal day.
- Prefer one bullet per PR-sized unit when it reads naturally.
- Split a large PR into 2 short bullets only when it clearly spans separate user-visible work.
- Group standalone commits by topic, but avoid long compound bullets.
- Use plain verbs such as `修正`, `改善`, `調整`, `変更`, `移行`, `追加`.
- Include commit hashes only when the user asks for evidence or traceability.
- If no matching commits are found, say that no commits were found for the resolved date and show the exact date window checked.

## Commands

Run from the target repository:

```bash
python3 /Users/masashiaso/.codex/skills/git-daily-report/scripts/collect_git_day.py --date YYYY-MM-DD
```

Useful options:

- `--date today`, `--date yesterday`, `--date day-before-yesterday`, or `--date YYYY-MM-DD`
- `--author "Author Name"` to force an author filter
- `--all-authors` to include everyone
- `--timezone Asia/Tokyo` when the environment timezone is unclear
- `--pr-search-days 365` to control how far around the target date PR merge commits are scanned

The script prints the resolved window, PR units, standalone commits, and file stats. Use `pull_requests` as the primary source material and `standalone_commits` as fallback material; do not paste the raw output unless asked.
