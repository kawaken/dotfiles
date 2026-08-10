#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command')

# grep/rg, find/ls, cat/head/tail, sed/awk のブロックは無効化中
# （Grep/Globツールが配布されないセッションがあり、代替不可能な詰みが発生するため）

# python3 -m json.tool をブロックし jq empty を案内
if echo "$COMMAND" | grep -qE 'python3?\s+-m\s+json\.tool'; then
  echo "Blocked: JSON検証には jq empty を使ってください（例: jq empty file.json）。" >&2
  exit 2
fi

# gh --jq の長いフィルターをブロック
if echo "$COMMAND" | grep -qE 'gh\s+.*--jq\s'; then
  GH_JQ_FILTER=$(echo "$COMMAND" | grep -oE "\-\-jq\s+'[^']*'" | head -1 | grep -oE "'[^']*'" | tr -d "'")
  if [[ -z "$GH_JQ_FILTER" ]]; then
    GH_JQ_FILTER=$(echo "$COMMAND" | grep -oE '\-\-jq\s+"[^"]*"' | head -1 | grep -oE '"[^"]*"' | tr -d '"')
  fi
  if [[ ${#GH_JQ_FILTER} -gt 30 ]]; then
    echo "Blocked: gh --jq のフィルターが長すぎます（${#GH_JQ_FILTER}文字）。jq -f を使ってください。" >&2
    exit 2
  fi
fi

exit 0
