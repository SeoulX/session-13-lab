#!/usr/bin/env bash
# Gate a script on Claude's binary answer. YES/NO pattern is cheap +
# unambiguous; any other reply becomes non-zero exit downstream.
set -e

answer=$(claude -p "Reply exactly the word YES if today is a weekday, otherwise NO.")
case "$answer" in
  YES) echo "guard passed"; exit 0 ;;
  NO)  echo "guard failed — non-weekday deploy blocked"; exit 1 ;;
  *)   echo "unexpected reply from Claude: $answer"; exit 2 ;;
esac
