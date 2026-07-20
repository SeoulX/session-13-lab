# Module 02 — Structured output

## Goal
Pipe Claude's output into `jq` + downstream tools.

## Flavours
- `--output-format json` — one envelope: `{ result, sessionId, totalCost, ... }`. Best for one-shot.
- `--output-format stream-json` — one JSON event per line as Claude works (`message` / `tool_use` / `tool_result` / `result`). Best for long runs + live monitoring.

## Try it

```bash
# Envelope
./envelope.sh

# Streamed
./stream.sh
```

Both write logs to `/tmp/`. Follow-up:

```bash
./cost.sh /tmp/claude-stream.log
```

## Formative check
Extract only the file paths Claude touched during a run. Answer in `check.sh`.
