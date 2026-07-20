#!/usr/bin/env bash
# Formative check answer: fail script when Claude reports any ghp_* leak.
set -e

# Feed the working dir listing via stdin as context.
report=$(ls -la | claude -p "Reply 'LEAK' if you see any file whose name starts with 'ghp_'. Otherwise reply 'CLEAN'.")
[ "$report" = "CLEAN" ] || { echo "leak detected"; exit 1; }
echo "clean"
