"""Regression checks for Codex palette conversation names and limits."""

import json
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import unittest


class SessionListingTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)
        self.database = self.directory / "state_5.sqlite"
        with sqlite3.connect(self.database) as db:
            db.execute("""
                CREATE TABLE threads (
                    id TEXT, name TEXT, title TEXT, updated_at INTEGER,
                    git_branch TEXT, archived INTEGER, source TEXT,
                    thread_source TEXT, cwd TEXT
                )
            """)

    def add_session(self, session_id, name, title, updated_at):
        with sqlite3.connect(self.database) as db:
            db.execute(
                "INSERT INTO threads VALUES (?, ?, ?, ?, NULL, 0, 'vscode', 'user', ?)",
                (session_id, name, title, updated_at, str(self.directory)),
            )

    def list_sessions(self, limit=100):
        script = Path(__file__).with_name("list-sessions.py")
        result = subprocess.run(
            [sys.executable, str(script), "--limit", str(limit)],
            cwd=self.directory,
            env={**os.environ, "CODEX_HOME": str(self.directory), "PWD": str(self.directory)},
            capture_output=True,
            text=True,
            check=True,
        )
        return json.loads(result.stdout)

    def test_empty_drafts_do_not_displace_recent_conversations(self):
        for index in range(6):
            self.add_session(f"draft-{index}", None, "", 100 + index)
        for index in range(5):
            self.add_session(f"conversation-{index}", None, f"Conversation {index}", index)
        rows = self.list_sessions(limit=5)
        self.assertEqual([row["id"] for row in rows], [f"conversation-{index}" for index in reversed(range(5))])

    def test_current_saved_names_take_precedence_and_blank_names_use_titles(self):
        self.add_session("renamed", "Previous name", "Original prompt", 3)
        self.add_session("title", "   ", "Actual title", 2)
        self.add_session("name-only", "Saved name", "", 1)
        self.assertEqual(
            [row["title"] for row in self.list_sessions()],
            ["Previous name", "Actual title", "Saved name"],
        )
        with sqlite3.connect(self.database) as db:
            db.execute("UPDATE threads SET name = 'Current name' WHERE id = 'renamed'")
        self.assertEqual(self.list_sessions()[0]["title"], "Current name")


if __name__ == "__main__":
    unittest.main()
