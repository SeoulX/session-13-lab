#!/usr/bin/env bash
# Sum the totalCost from a stream-json log.
set -e
: "${1:?usage: $0 <path-to-stream-json-log>}"

jq -r 'select(.type == "result") | .totalCost' "$1" \
  | awk '{s+=$1} END {printf "total cost: $%.4f\n", s}'
