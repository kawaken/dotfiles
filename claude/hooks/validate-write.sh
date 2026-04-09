#!/usr/bin/env zsh
INPUT=$(cat)
FILE_PATH=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.file_path')

# パスを正規化して /tmp/ へのアクセスをブロック
# RESOLVED=${FILE_PATH:A}
# if [[ "$RESOLVED" == /tmp/* || "$RESOLVED" == /private/tmp/* ]]; then
#   REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
#   FILENAME=${RESOLVED##*/}
#   echo "Blocked: /tmp/ への書き込みは禁止です。${REPO_ROOT}/tmp/${FILENAME} を使ってください（なければ mkdir -p ${REPO_ROOT}/tmp/ で作成）。" >&2
#   exit 2
# fi

exit 0
