#!/usr/bin/env bash
# Writes an intentionally buggy .py so parallel-local.sh has something
# for Claude to actually flag. Run BEFORE parallel-local.sh.
set -e

cat > buggy.py <<'EOF'
def divide(a, b):
    return a / b   # missing zero check

def first(xs):
    return xs[0]   # index error on empty

def parse_int(s):
    return int(s)  # ValueError on non-numeric — no try/except
EOF

git add buggy.py 2>/dev/null || true
echo "buggy.py written + staged. Now run:"
echo "  ./parallel-local.sh"
