#!/usr/bin/env bash
set -e
: "${1:?usage: $0 <log>}"

jq -r 'select(.type == "result") | .total_cost_usd // .totalCost // 0' "$1" \
  | awk '{s+=$1} END {printf "sessions: %d, total cost: $%.4f\n", NR, s}'
