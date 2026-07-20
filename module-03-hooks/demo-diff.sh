#!/usr/bin/env bash
# Writes a file w/ a fake github token so the hook can be tested end-to-end.
# Real ghp_ tokens are 40 chars — this is a syntactically-valid stub.
set -e

cat > leak.txt <<'EOF'
# secret rotation ticket — do not merge
GITHUB_TOKEN=ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
EOF

echo "leak.txt written. Now:"
echo "  git add leak.txt && git commit -m test"
echo "Hook should fire + block."
