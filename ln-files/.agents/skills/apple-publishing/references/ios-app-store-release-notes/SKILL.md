---
name: ios-app-store-release-notes
description: Draft concise iOS App Store release notes from Git history. Use when Codex needs to inspect the latest Git tag through HEAD, summarize iOS app changes, write App Store Connect "What's New" text, localize release notes, or prepare user-facing iOS release copy from commits, PR titles, tags, or changelog evidence.
---

# iOS App Store Release Notes

## Workflow

1. Confirm the current repository and branch with `git status --short --branch`.
2. Collect release evidence from the latest reachable tag to `HEAD`.
   - Prefer `scripts/collect_release_context.py <repo>` for consistent output.
   - If the user specifies a tag or range, pass `--from <tag-or-ref>` or `--range <rev-range>`.
   - If `HEAD` is already tagged, use the previous reachable tag as the release boundary unless the user explicitly asks for an empty latest-tag-to-HEAD check.
3. Read the evidence before writing copy.
   - Use commit subjects, PR references, changed paths, and tag names.
   - If App Store metadata exists, inspect likely files such as `metadata/*/release_notes.txt`, `fastlane/metadata/*/release_notes.txt`, or `metadata/*/whats_new.txt` for tone and length.
4. Draft only user-facing release notes.
   - Mention features, improvements, supported languages, content updates, and fixes that users can understand.
   - Omit internal refactors, dependency bumps, CI changes, test-only changes, and implementation details unless they directly affect users.
5. Keep the final note App Store-ready.
   - Stay under 4,000 characters.
   - Prefer 2-5 short bullets or 1 short paragraph.
   - Do not include Markdown headings unless the user asks for a draft document.
   - Do not invent changes not supported by evidence.
6. Report the tag range used and any uncertainty separately from the release note body.

## Evidence Collection

Run:

```bash
python3 /path/to/skill/scripts/collect_release_context.py .
```

Useful options:

```bash
python3 /path/to/skill/scripts/collect_release_context.py . --from v1.2.3
python3 /path/to/skill/scripts/collect_release_context.py . --range v1.2.3..HEAD
python3 /path/to/skill/scripts/collect_release_context.py . --max-commits 120
```

If the script cannot find a tag, it reports all reachable history and uses the empty tree for changed-file evidence. Say that no tag was found.

## Writing Rules

- Write in the App Store listing language requested by the user. If no language is specified, match the user's language.
- For Japanese release notes, use concise polite plain business copy. Avoid hype, vague atmosphere words, and internal project names.
- For English release notes, use direct user-facing language and avoid engineering jargon.
- Convert technical commit language into user impact:
  - `fix crash on launch` -> "Fixed an issue that could cause the app to close unexpectedly on launch."
  - `add widget deep link` -> "Added support for opening relevant screens from widgets."
  - `refactor auth service` -> omit unless it changed user-visible behavior.
- If evidence is thin, write a conservative note such as "軽微な不具合修正と安定性の改善を行いました。" and explain the lack of specific user-facing commits separately.

## Output Format

Return:

```markdown
リリースノート:
<App Store-ready text>

確認:
- 範囲: <tag>..HEAD
- 根拠: <brief evidence summary>
- 懸念: <only if needed>
```

If the user asks only for the text to paste into App Store Connect, return only the release note body.
