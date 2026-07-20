#!/usr/bin/env bash
# Live-follow the audit log + filter for tool calls.
set -e
log=${1:-/tmp/claude-audit.log}

tail -f "$log" \
  | jq -r --unbuffered 'select(.type == "tool_use") | "[\(.timestamp // "-")] \(.name) \(.input.file_path // "")"'
