#!/usr/bin/env bash
# JSON envelope — one blob returned after Claude finishes.
set -e

claude -p --output-format json \
  "list the top-level files/dirs in this repo, one per line" \
  | tee /tmp/claude-envelope.json \
  | jq -r '.result'
