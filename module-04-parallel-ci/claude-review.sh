#!/usr/bin/env bash
# Jenkins-invoked review. Emits JSON findings for downstream aggregation.
set -e

diff=$(git diff origin/main..HEAD -- '*.py' '*.ts' '*.tsx' '*.go' '*.rs' '*.js' 2>/dev/null || true)
if [ -z "$diff" ]; then
  echo '{"findings": [], "note": "no code diff to review"}' > claude-review.json
  exit 0
fi

echo "$diff" | claude -p --output-format json \
  "Review this diff for logic bugs, off-by-one, missing null checks, or unsafe patterns. Reply strict JSON: {\"findings\":[{\"file\":\"...\",\"severity\":\"low|med|high\",\"note\":\"...\"}]}" \
  | jq '.result | fromjson' > claude-review.json

count=$(jq '.findings | length' claude-review.json)
echo "→ Claude review complete: $count findings (archived)"
