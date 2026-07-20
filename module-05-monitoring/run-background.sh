#!/usr/bin/env bash
# Background Claude — output redirected to /tmp/claude-audit.log.
set -e

log=/tmp/claude-audit.log
nohup claude -p --output-format stream-json \
  "list every .md file in this repo w/ its first heading" \
  > "$log" 2>&1 &

echo "backgrounded pid=$!"
echo "log: $log"
echo "tail w/: ./tail-live.sh"
