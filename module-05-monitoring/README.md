# Module 05 — Monitoring background agents

## Goal
Watch what Claude is doing when nobody's driving. Cost accounting after the fact.

## Where session logs live
```
~/.claude/projects/<sanitized-repo-path>/<session-id>.jsonl
```

One JSON event per line — same shape as `--output-format stream-json`.

## Files
- `run-background.sh` — kicks off an unattended run in the background.
- `tail-live.sh` — filters the live log for tool calls.
- `cost.sh` — sums totalCost across all events.

## Try it

```bash
./run-background.sh    # writes to /tmp/claude-audit.log, backgrounds
./tail-live.sh &       # live filter — Ctrl-C when done
./cost.sh /tmp/claude-audit.log
```

## Design notes
- `--unbuffered` on jq matters — without it, matches sit in a 4kB pipe buffer for minutes.
- For long runs, redirect stdout to a file + tail it. Don't rely on scrollback.
