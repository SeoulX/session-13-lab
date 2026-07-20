#!/usr/bin/env bash
# Pre-commit gate. Two rules:
#   1. Hard-fail if Claude reports a secret leak in the staged diff.
#   2. Warn (never block) if pulse-align compliance fails for devops/ changes.
#
# Override w/ `git commit --no-verify` for emergencies.

set -e

diff=$(git diff --cached)
[ -z "$diff" ] && exit 0

# --- Rule 1: secret leak (hard-fail) ---
# Claude sometimes adds prose after the JSON — grep the first {...} match.
leak_json=$(echo "$diff" | claude -p --output-format json \
  --append-system-prompt "Reply with ONLY a single JSON object, no prose." \
  "Any GitHub/Slack/LLM tokens, private keys, or high-entropy secrets in this diff? Reply {\"leak\": true|false}" \
  | jq -r '.result' \
  | grep -oE '\{[^}]*\}' | head -1)
if [ "$(echo "$leak_json" | jq -r '.leak // false' 2>/dev/null)" = "true" ]; then
  echo "❌ Suspected secret in staged diff. Use --no-verify to override." >&2
  exit 1
fi

# --- Rule 2: pulse-align compliance on devops/ changes (warn-only) ---
if git diff --cached --name-only | grep -q '^devops/'; then
  echo "→ devops/ changed; running pulse-align compliance (warn-only)"
  compliant_json=$(claude -p --output-format json \
    --append-system-prompt "Reply with ONLY a single JSON object, no prose." \
    "Check pulse-align compliance for this repo. Reply {\"compliant\": true|false}" \
    | jq -r '.result' \
    | grep -oE '\{[^}]*\}' | head -1)
  if [ "$(echo "$compliant_json" | jq -r '.compliant // false' 2>/dev/null)" != "true" ]; then
    echo "⚠️  pulse-align compliance failed. Not blocking — Trivy will catch it in CI." >&2
  fi
fi

exit 0
