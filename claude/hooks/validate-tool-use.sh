#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command')

# grep / rg → Grep ツール
if echo "$COMMAND" | grep -qE '^\s*(grep|rg|egrep|fgrep)\b'; then
  echo "Blocked: grep/rg は Grep ツールを使ってください。" >&2
  exit 2
fi

# find / ls → Glob ツール
if echo "$COMMAND" | grep -qE '^\s*(find|ls)\b'; then
  echo "Blocked: find/ls は Glob ツールを使ってください。" >&2
  exit 2
fi

# cat / head / tail（ファイル読み取り）→ Read ツール
if echo "$COMMAND" | grep -qE '^\s*(cat|head|tail)\b'; then
  echo "Blocked: cat/head/tail は Read ツールを使ってください。" >&2
  exit 2
fi

# sed / awk（ファイル編集）→ Edit ツール
if echo "$COMMAND" | grep -qE '^\s*(sed|awk)\b'; then
  echo "Blocked: sed/awk は Edit ツールを使ってください。" >&2
  exit 2
fi

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
