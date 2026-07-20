#!/usr/bin/env bash
# Live-follow the audit log + filter for tool calls.
set -e
log=${1:-/tmp/claude-audit.log}

tail -f "$log" \
  | jq -r --unbuffered '.message.content[]? | select(.type == "tool_use") | "\(.name) \(.input.file_path // .input.path // "")"'
