#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# 連続したクォート文字をブロック（'" や "' は複雑なクォーティングの兆候）
if [[ "$COMMAND" == *"'\""* ]] || [[ "$COMMAND" == *"\"'"* ]]; then
  echo "Blocked: 連続したクォート文字 ('\" or \"') を検出しました。クォーティングを見直し、複雑なフィルターは別ファイルに書いてください。" >&2
  exit 2
fi

# cd と他コマンドのチェインをブロック（cd は単独のBash呼び出しで実行すべき）
if echo "$COMMAND" | grep -qE 'cd\s+.*&&|cd\s+.*;'; then
  echo "Blocked: cd は単独のBash呼び出しで実行してください。&& や ; で他のコマンドとチェインしないでください。" >&2
  exit 2
fi

# jq の長いインラインフィルターをブロック（30文字超は jq -f を使うべき）
if echo "$COMMAND" | grep -qE '\bjq\b' && ! echo "$COMMAND" | grep -qE '\bjq\s+(-f|--from-file)\b'; then
  JQ_FILTER=$(echo "$COMMAND" | grep -oE "jq\s+(-[a-zA-Z]\s+)*'[^']*'" | head -1 | grep -oE "'[^']*'" | tr -d "'")
  if [[ -z "$JQ_FILTER" ]]; then
    JQ_FILTER=$(echo "$COMMAND" | grep -oE 'jq\s+(-[a-zA-Z]\s+)*"[^"]*"' | head -1 | grep -oE '"[^"]*"' | tr -d '"')
  fi
  if [[ ${#JQ_FILTER} -gt 30 ]]; then
    echo "Blocked: jq のフィルターが長すぎます（${#JQ_FILTER}文字）。.jq ファイルに書いて jq -f で実行してください。" >&2
    exit 2
  fi
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
