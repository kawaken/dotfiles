#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command')

# コマンド引数中の ! をブロック（zshのhistory expansionで \! にエスケープされる）
# word! パターン（Rubyのbang method等）を検出
if echo "$COMMAND" | grep -qE '[a-zA-Z_]!'; then
  echo "Blocked: コマンド引数に ! が含まれています（例: update!）。zshで \\! にエスケープされます。heredoc（<<'EOF'）経由で渡してください。" >&2
  exit 2
fi

exit 0
