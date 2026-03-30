#!/usr/bin/env zsh
INPUT=$(cat)

STOP_HOOK_ACTIVE=$(printf '%s\n' "$INPUT" | jq -r '.stop_hook_active')
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
  exit 0
fi

TRANSCRIPT_PATH=$(printf '%s\n' "$INPUT" | jq -r '.transcript_path')
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

USER_COUNT=$(grep -cE '"role"\s*:\s*"user"' "$TRANSCRIPT_PATH" 2>/dev/null)
if [[ -z "$USER_COUNT" ]]; then
  USER_COUNT=0
fi

if [[ $USER_COUNT -ge 20 && $((USER_COUNT % 20)) -eq 0 ]]; then
  printf '{"decision":"block","reason":"セッションが長くなってきたで（ユーザーメッセージ: %d回）。作業の区切りで /retro を実行して振り返りしよう。"}\n' "$USER_COUNT"
fi

exit 0
