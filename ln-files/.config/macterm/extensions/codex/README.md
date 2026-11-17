# Codex for Macterm

Open the command palette with Command-P and select Codex.

- New Session starts Codex in a new tab in the current project.
- New Session in Worktree runs `codex --worktree` in a new tab to start a session in a new managed Git worktree.
- The first screen shows up to 100 conversations in the current project, newest first. Search by title, branch, or session ID.
- Select a conversation to run `codex resume <session-id>` in a new tab.
- Use Option-Return or Option-click to open a new session or resume a conversation in a split.

Requires `codex` and `python3` on the shell PATH.
To bind a key to the palette, use Settings > Keymaps > Extensions > Codex.
The key opens the palette. Press Return on New Session to start Codex.

## Session listing

The helper reads the highest-numbered `state_*.sqlite` in `CODEX_HOME`, or `~/.codex` when that variable is unset.
It opens the database in read-only mode and reads conversation metadata only.
It selects CLI and app/IDE user conversations whose saved working directory matches the project directory.
Archived conversations, non-interactive runs, sub-agent conversations, and unnamed empty sessions are excluded.
Each listing reads the current saved names. A saved name takes precedence over the original conversation title.
No Codex process starts until you select a new session action or a conversation.

This personal extension uses the internal database schema checked with Codex CLI 0.167.1.
A Codex update can change that schema. A read failure appears as a palette error rather than an empty successful list.
A missing database means there are no saved conversations yet, so the list is empty.
The helper does not read conversation messages or change Codex settings or history.
