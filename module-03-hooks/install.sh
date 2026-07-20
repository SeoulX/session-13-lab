#!/usr/bin/env bash
# Copy pre-commit.sh into the current repo's .git/hooks/ dir.
set -e
[ -d .git ] || { echo "not a git repo — run this from repo root"; exit 1; }

src="$(dirname "$0")/pre-commit.sh"
dst=".git/hooks/pre-commit"

cp "$src" "$dst"
chmod +x "$dst"
echo "installed: $dst"
