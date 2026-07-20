# Module 01 — Non-interactive Claude (`claude -p`)

## Goal
Fire Claude from a shell without opening the REPL. Consume its output like any CLI.

## Rules
- **Carries**: `~/.claude` settings, project `CLAUDE.md`, MCP config, allowed-tools.
- **Doesn't**: prior conversation, plan mode, todo list.
- **Exit code**: 0 = ran, non-zero = failed. Gate scripts on it.

## Try it

```bash
# One-shot
./demo.sh

# Guard-rail example
./guard.sh
```

## Formative check
Write a one-liner that exits non-zero if Claude reports the current dir has any `ghp_*` string. Answer in `check.sh`.
