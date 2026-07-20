#!/usr/bin/env bash
# Local equivalent of the .github/workflows/04-parallel-ci.yml job matrix.
# Fires test + lint + claude-review in parallel via bash background jobs,
# waits for all, prints a single summary.
#
# Same parallelism model as GHA "jobs w/o needs:" or Jenkins "parallel { }":
#   total wall-clock = max(job), not sum.
#
# Usage: ./parallel-local.sh
set -e

BASE_REF=${BASE_REF:-HEAD~1}
LOG_DIR=/tmp/s13-parallel
rm -rf "$LOG_DIR" && mkdir -p "$LOG_DIR"

echo "→ Running 3 checks in parallel (base=$BASE_REF)"
start=$(date +%s)

# --- Job 1: test (simulated) ---
(
  echo "[test] starting"
  # Real repos would call: ./devops/test.sh  or  pytest / npm test / cargo test
  sleep 3
  echo "[test] passed"
) > "$LOG_DIR/test.log" 2>&1 &
TEST_PID=$!

# --- Job 2: lint (simulated) ---
(
  echo "[lint] starting"
  sleep 2
  echo "[lint] passed"
) > "$LOG_DIR/lint.log" 2>&1 &
LINT_PID=$!

# --- Job 3: claude-review (real) ---
(
  echo "[claude] starting"
  # Prefer staged diff (matches CI pre-merge case). Fall back to
  # committed diff against base ref when nothing is staged.
  diff=$(git diff --cached -- '*.py' '*.ts' '*.tsx' '*.go' '*.js' '*.sh' 2>/dev/null || true)
  if [ -z "$diff" ]; then
    diff=$(git diff "$BASE_REF"..HEAD -- '*.py' '*.ts' '*.tsx' '*.go' '*.js' '*.sh' 2>/dev/null || true)
  fi
  if [ -z "$diff" ]; then
    echo '{"findings":[],"note":"no code diff"}' > "$LOG_DIR/claude-review.json"
  else
    echo "$diff" | claude -p --output-format json \
      --append-system-prompt "Reply with ONLY a single JSON object, no prose." \
      "Review this diff for logic bugs, off-by-one, missing null checks, unsafe patterns. Reply {\"findings\":[{\"file\":\"...\",\"severity\":\"low|med|high\",\"note\":\"...\"}]}" \
      | jq -r '.result' \
      | grep -oE '\{.*\}' | head -1 > "$LOG_DIR/claude-review.json" || echo '{"findings":[]}' > "$LOG_DIR/claude-review.json"
  fi
  count=$(jq '.findings | length' "$LOG_DIR/claude-review.json" 2>/dev/null || echo 0)
  echo "[claude] $count findings"
) > "$LOG_DIR/claude.log" 2>&1 &
CLAUDE_PID=$!

# Wait for all three
wait $TEST_PID   && test_rc=0 || test_rc=$?
wait $LINT_PID   && lint_rc=0 || lint_rc=$?
wait $CLAUDE_PID && claude_rc=0 || claude_rc=$?

elapsed=$(( $(date +%s) - start ))

echo ""
echo "─── results (wall-clock ${elapsed}s) ───"
printf "  test          : %s (rc=%d)\n" "$(tail -1 "$LOG_DIR/test.log")" "$test_rc"
printf "  lint          : %s (rc=%d)\n" "$(tail -1 "$LOG_DIR/lint.log")" "$lint_rc"
printf "  claude-review : %s (rc=%d)\n" "$(tail -1 "$LOG_DIR/claude.log")" "$claude_rc"
echo ""
echo "logs: $LOG_DIR/{test,lint,claude}.log"
echo "findings JSON: $LOG_DIR/claude-review.json"

# Optional preview of the findings
if [ -s "$LOG_DIR/claude-review.json" ]; then
  echo ""
  echo "─── findings preview ───"
  jq '.' "$LOG_DIR/claude-review.json" 2>/dev/null || cat "$LOG_DIR/claude-review.json"
fi
