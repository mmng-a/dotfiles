"""Check ownership, reuse, and shutdown boundaries without touching live browsers."""

import contextlib
import importlib.machinery
import importlib.util
import json
import os
import sqlite3
import subprocess
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

loader = importlib.machinery.SourceFileLoader("codex_browser", str(Path(__file__).parents[1] / "bin/codex-browser"))
spec = importlib.util.spec_from_loader(loader.name, loader)
browser = importlib.util.module_from_spec(spec)
loader.exec_module(browser)


class BrowserLifecycleTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.state = Path(self.temporary.name)
        self.addCleanup(patch.stopall)
        patch.object(browser, "STATE", self.state).start()
        patch.object(browser, "THREAD_DB", self.state / "threads.sqlite").start()
        chrome = self.state / "Google Chrome for Testing"
        chrome.touch()
        patch.object(browser, "CHROME", chrome).start()
        patch.dict(os.environ, {"CODEX_THREAD_ID": "parent"}).start()
        self.owner = {"pid": 123, "identity": "known-codex-process"}
        self.identity_reader = browser.process_identity
        patch.object(browser, "process_identity", return_value=self.owner["identity"]).start()
        patch.object(browser, "codex_owner", return_value=self.owner).start()
        self.register("parent")

    def metadata(self, rows):
        with contextlib.closing(sqlite3.connect(browser.THREAD_DB)) as database:
            database.execute("CREATE TABLE threads (id TEXT PRIMARY KEY, source TEXT, archived INTEGER)")
            database.executemany("INSERT INTO threads VALUES (?, ?, ?)", rows)
            database.commit()

    def register(self, root):
        browser.save(browser.record_path(root), {"root": root, "owner": self.owner,
                                               "ended": False, "modes": {}})

    def mode(self, root="parent", name="headless", pid=321, keep=False):
        mode = {"session": browser.session_id(root, name), "pid": pid,
                "started": "2026-10-29T00:00:00Z", "keep_open": keep}
        entry = browser.load(browser.record_path(root))
        entry["modes"][name] = mode
        browser.save(browser.record_path(root), entry)
        return mode

    def response(self, mode):
        return {"pid": mode["pid"], "startDate": mode["started"]}

    def test_subagent_inherits_its_parent_browser(self):
        browser.hook({"hook_event_name": "SubagentStart", "session_id": "parent", "agent_id": "child"})
        browser.hook({"hook_event_name": "SubagentStart", "session_id": "child", "agent_id": "grandchild"})
        self.assertEqual(browser.root_for("child"), "parent")
        self.assertEqual(browser.root_for("grandchild"), "parent")

    def test_roots_and_display_modes_have_distinct_valid_session_ids(self):
        sessions = {browser.session_id(root, mode) for root in ("parent", "other")
                    for mode in ("headed", "headless")}
        self.assertEqual(len(sessions), 4)
        for session in sessions:
            self.assertRegex(session, r"^[a-f0-9-]+$")

    def test_status_does_not_start_a_browser(self):
        with patch.object(browser, "status", return_value=None), patch.object(browser.subprocess, "run") as run:
            run.return_value.returncode = 0
            self.assertEqual(browser.run(["status"]), 0)
        self.assertEqual(run.call_count, 1)
        self.assertEqual(run.call_args.args[0][1], "status")
        self.assertEqual(browser.load(browser.record_path("parent"))["modes"], {})

    def test_first_operation_starts_once_and_later_operations_reuse_it(self):
        response = {"pid": 321, "startDate": "now"}
        with patch.object(browser, "status", side_effect=[None, response, response]), \
             patch.object(browser.subprocess, "run") as run:
            run.return_value.returncode = 0
            browser.run(["list_pages"])
            browser.run(["list_pages"])
        self.assertEqual([c.args[0][1] for c in run.call_args_list], ["start", "list_pages", "list_pages"])
        self.assertEqual(browser.load(browser.record_path("parent"))["modes"]["headless"]["pid"], 321)
        startup = run.call_args_list[0].args[0]
        self.assertEqual(startup[startup.index("--executablePath") + 1], str(browser.CHROME))

    def test_foreign_or_replaced_daemon_is_never_used(self):
        self.mode()
        with patch.object(browser, "status", return_value={"pid": 999, "startDate": "other"}), \
             patch.object(browser.subprocess, "run") as run:
            with self.assertRaisesRegex(RuntimeError, "identity changed"):
                browser.run(["list_pages"])
        run.assert_not_called()

    def test_permission_failure_does_not_spawn_a_replacement(self):
        with patch.object(browser, "status", side_effect=PermissionError("blocked")), \
             patch.object(browser.subprocess, "run") as run:
            with self.assertRaises(PermissionError):
                browser.run(["list_pages"])
        run.assert_not_called()

    def test_session_end_marks_owner_and_detaches_cleanup(self):
        with patch.object(browser.subprocess, "Popen") as popen:
            browser.hook({"hook_event_name": "SessionEnd", "session_id": "parent"})
        self.assertTrue(browser.load(browser.record_path("parent"))["ended"])
        self.assertTrue(popen.call_args.kwargs["start_new_session"])

    def test_cleanup_preserves_another_live_thread(self):
        self.register("other")
        first = self.mode()
        self.mode("other", pid=456)
        entry = browser.load(browser.record_path("parent")); entry["ended"] = True
        browser.save(browser.record_path("parent"), entry)
        with patch.object(browser, "process_identity", return_value=self.owner["identity"]), \
             patch.object(browser, "status", return_value=self.response(first)), \
             patch.object(browser.subprocess, "run") as run:
            browser.reap()
        self.assertFalse(browser.record_path("parent").exists())
        self.assertTrue(browser.record_path("other").exists())
        self.assertEqual(run.call_count, 1)
        self.assertIn(first["session"], run.call_args.args[0])

    def test_dead_or_reused_owner_pid_is_reclaimed(self):
        mode = self.mode()
        with patch.object(browser, "process_identity", return_value="different process"), \
             patch.object(browser, "status", return_value=self.response(mode)), \
             patch.object(browser.subprocess, "run") as run:
            browser.reap()
        self.assertFalse(browser.record_path("parent").exists())
        self.assertEqual(run.call_count, 1)

    def test_kept_joint_view_survives_until_explicit_release(self):
        mode = self.mode(name="headed", keep=True)
        entry = browser.load(browser.record_path("parent")); entry["ended"] = True
        browser.save(browser.record_path("parent"), entry)
        with patch.object(browser, "status", return_value=self.response(mode)), \
             patch.object(browser.subprocess, "run") as run:
            browser.reap()
            run.assert_not_called()
            browser.reap(force_root="parent")
        self.assertFalse(browser.record_path("parent").exists())
        self.assertEqual(run.call_count, 1)

    def test_replaced_daemon_is_not_killed_during_cleanup(self):
        self.mode()
        entry = browser.load(browser.record_path("parent")); entry["ended"] = True
        browser.save(browser.record_path("parent"), entry)
        with patch.object(browser, "status", return_value={"pid": 999, "startDate": "other"}), \
             patch.object(browser.subprocess, "run") as run:
            with self.assertRaisesRegex(RuntimeError, "identity changed"):
                browser.reap()
        run.assert_not_called()
        self.assertTrue(browser.record_path("parent").exists())

    def test_manual_session_override_is_rejected(self):
        with self.assertRaises(ValueError):
            browser.run(["list_pages", "--sessionId", "123"])

    def test_unregistered_thread_is_registered_on_first_use(self):
        with patch.dict(os.environ, {"CODEX_THREAD_ID": "missing"}), \
             patch.object(browser, "status", side_effect=[None, {"pid": 321, "startDate": "now"}]), \
             patch.object(browser.subprocess, "run") as run:
            run.return_value.returncode = 0
            self.assertEqual(browser.run(["list_pages"]), 0)
        entry = browser.load(browser.record_path("missing"))
        self.assertEqual(entry["owner"], self.owner)
        self.assertFalse(entry["ended"])
        self.assertEqual(entry["modes"]["headless"]["pid"], 321)

    def test_ended_thread_is_registered_again_when_resumed(self):
        entry = browser.load(browser.record_path("parent")); entry["ended"] = True
        browser.save(browser.record_path("parent"), entry)
        with patch.object(browser, "status", return_value=None), patch.object(browser.subprocess, "run") as run:
            run.return_value.returncode = 0
            browser.run(["status"])
        self.assertFalse(browser.load(browser.record_path("parent"))["ended"])
        self.assertEqual(run.call_args.args[0][1], "status")

    def test_metadata_recovers_parent_after_a_missed_subagent_hook(self):
        source = json.dumps({"subagent": {"thread_spawn": {"parent_thread_id": "parent"}}})
        self.metadata([("child", source, 0), ("parent", "cli", 0)])
        self.assertEqual(browser.root_for("child"), "parent")

    def test_unavailable_metadata_keeps_the_thread_independent(self):
        self.assertEqual(browser.root_for("unknown"), "unknown")

    def test_archived_thread_is_reclaimed_without_an_end_hook(self):
        mode = self.mode()
        self.metadata([("parent", "cli", 1)])
        with patch.object(browser, "status", return_value=self.response(mode)), \
             patch.object(browser.subprocess, "run") as run:
            browser.reap()
        self.assertFalse(browser.record_path("parent").exists())
        self.assertEqual(run.call_count, 1)

    def test_missing_testing_chrome_never_launches_normal_chrome(self):
        browser.CHROME.unlink()
        with patch.object(browser, "status", return_value=None), patch.object(browser.subprocess, "run") as run:
            with self.assertRaisesRegex(RuntimeError, "Chrome for Testing"):
                browser.run(["list_pages"])
        run.assert_not_called()

    def test_visible_mode_uses_the_same_testing_chrome(self):
        with patch.object(browser, "status", side_effect=[None, {"pid": 321, "startDate": "now"}]), \
             patch.object(browser.subprocess, "run") as run:
            run.return_value.returncode = 0
            browser.run(["--headed", "list_pages"])
        startup = run.call_args_list[0].args[0]
        self.assertIn("--no-headless", startup)
        self.assertEqual(startup[startup.index("--executablePath") + 1], str(browser.CHROME))

    def test_owner_identity_is_stable_across_locale_and_timezone(self):
        def ps_result(command, **kwargs):
            identity = "stable" if kwargs["env"].get("LC_ALL") == "C" and kwargs["env"].get("TZ") == "UTC" else "localized"
            return subprocess.CompletedProcess(command, 0, stdout=identity, stderr="")
        with patch.object(browser.subprocess, "run", side_effect=ps_result):
            with patch.dict(os.environ, {"LANG": "ja_JP.UTF-8", "TZ": "Asia/Tokyo"}):
                japanese = self.identity_reader(123)
            with patch.dict(os.environ, {"LANG": "en_US.UTF-8", "TZ": "America/New_York"}):
                english = self.identity_reader(123)
        self.assertEqual(japanese, "stable")
        self.assertEqual(japanese, english)


if __name__ == "__main__":
    unittest.main()
