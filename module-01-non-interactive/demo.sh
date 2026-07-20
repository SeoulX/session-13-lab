#!/usr/bin/env bash
# One-shot Claude query. Output printed to stdout, no interactive REPL.
set -e
claude -p "Say hello and confirm you're running non-interactively."
