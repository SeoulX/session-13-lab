#!/usr/bin/env bash
# Answer: pull file paths from every tool_use event that carries one.
set -e
: "${1:?usage: $0 <path-to-stream-json-log>}"

jq -r 'select(.type == "tool_use") | .input.file_path // empty' "$1" \
  | sort -u
