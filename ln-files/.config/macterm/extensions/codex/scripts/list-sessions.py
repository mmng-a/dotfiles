#!/usr/bin/env python3
"""List this project's Codex conversations without changing the session store."""

import argparse
from contextlib import closing
from datetime import datetime
import json
import os
from pathlib import Path
import re
import sqlite3
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, default=100)
    args = parser.parse_args()
    if args.limit < 1:
        parser.error("--limit must be positive")

    home = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser()
    databases = []
    for path in home.glob("state_*.sqlite"):
        match = re.fullmatch(r"state_(\d+)\.sqlite", path.name)
        if match:
            databases.append((int(match[1]), path))
    if not databases:
        print("[]")
        return

    database = max(databases)[1].resolve()
    cwd = os.getcwd()
    logical_cwd = os.environ.get("PWD", cwd)
    if os.path.realpath(logical_cwd) != os.path.realpath(cwd):
        logical_cwd = cwd
    query = """
        SELECT id, name, title, updated_at, git_branch
        FROM threads
        WHERE archived = 0
          AND source IN ('cli', 'vscode')
          AND (thread_source IS NULL OR thread_source IN ('user', 'voice_chat'))
          AND cwd IN (?, ?)
        ORDER BY updated_at DESC, id DESC
        LIMIT ?
    """
    with closing(sqlite3.connect(database.as_uri() + "?mode=ro", uri=True, timeout=2)) as db:
        rows = db.execute(query, (cwd, logical_cwd, args.limit)).fetchall()

    output = []
    for session_id, name, title, updated_at, branch in rows:
        label = next((line.strip() for line in (name or title or "").splitlines() if line.strip()), "Untitled session")
        subtitle = datetime.fromtimestamp(updated_at).strftime("%Y-%m-%d %H:%M")
        if branch:
            subtitle += " · " + branch
        output.append({"id": session_id, "title": label[:160], "subtitle": subtitle})
    print(json.dumps(output, ensure_ascii=False))


if __name__ == "__main__":
    try:
        main()
    except (OSError, sqlite3.Error, ValueError) as error:
        print("Cannot read Codex sessions: " + str(error), file=sys.stderr)
        sys.exit(1)
