#!/usr/bin/env bash
# stream-json — one event per line while Claude runs. `--unbuffered` on jq
# so tool calls flush live instead of batching.
set -e

claude -p --output-format stream-json \
  "read the README in this directory and echo its first heading" \
  | tee /tmp/claude-stream.log \
  | jq -r --unbuffered 'select(.type == "tool_use") | "→ \(.name) \(.input.file_path // "")"'
