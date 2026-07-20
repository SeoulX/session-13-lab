#!/usr/bin/env bash
# Sanity-check the capstone steps.
set -e

pass=0
fail=0
check() {
  if eval "$2" >/dev/null 2>&1; then
    printf "✓ %s\n" "$1"; pass=$((pass+1))
  else
    printf "✗ %s\n" "$1"; fail=$((fail+1))
  fi
}

check "M01 demo produced output"         "test -x $(dirname "$0")/../module-01-non-interactive/demo.sh"
check "M02 envelope log written"         "test -s /tmp/claude-envelope.json"
check "M02 stream log written"           "test -s /tmp/claude-stream.log"
check "M03 hook installed in some repo"  "find $HOME -maxdepth 4 -path '*/.git/hooks/pre-commit' 2>/dev/null | head -1 | grep -q ."
check "M04 Jenkins snippet exists"       "test -s $(dirname "$0")/../module-04-parallel-ci/Jenkinsfile.snippet"
check "M05 audit log written"            "test -s /tmp/claude-audit.log"

echo ""
echo "pass: $pass · fail: $fail"
[ "$fail" -eq 0 ] || exit 1
