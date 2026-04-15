#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command')

# git push --force はブロック（--force-with-lease は許可）
if echo "$COMMAND" | grep -qE 'git\s+push\b.*(\s--force([[:space:]]|$)|\s-f\b)'; then
  echo "Blocked: git push --force / -f は禁止です。--force-with-lease を使うか、通常の git push を使ってください。" >&2
  exit 2
fi

# 以下はブロックせず Claude への目立たないリマインダーとして出力する
REMINDERS=()

# cd と他コマンドのチェイン
if echo "$COMMAND" | grep -qE 'cd\s+.*&&|cd\s+.*;'; then
  REMINDERS+=("cd は単独のBash呼び出しで実行してください。&& や ; で他のコマンドとチェインしないでください。")
fi

# cd フルパス（同一ワークスペース内）
if echo "$COMMAND" | grep -qE '\bcd\s+/'; then
  CD_DEST=$(echo "$COMMAND" | grep -oE 'cd[[:space:]]+/[^[:space:]]+' | head -1 | sed 's/cd[[:space:]]*//')
  if [[ -n "$CD_DEST" && "$CD_DEST" == "${PWD}"* ]]; then
    REMINDERS+=("同じワークスペース内での cd はフルパスではなく相対パスを使ってください。")
  fi
fi

# git チェイン（git add → git commit は許可）
if ! echo "$COMMAND" | grep -qE '^git add [^&]+ && git commit( [^&]+)?$'; then
  if echo "$COMMAND" | grep -qE '\bgit\b.*&&.*\bgit\b'; then
    REMINDERS+=("git の操作を && でチェインしないでください。各 git コマンドは別々のBash呼び出しで実行してください。")
  fi
fi

# git -C によるディレクトリ指定
if echo "$COMMAND" | grep -qE '\bgit\b.*\s-C\s'; then
  REMINDERS+=("git -C でディレクトリを指定せず、cd でディレクトリ移動してから実行してください。")
fi

# 作業ディレクトリ指定オプション（yarn --cwd, npm --prefix 等）
if echo "$COMMAND" | grep -qE '(--cwd|--prefix|--directory)\s+[/~]'; then
  REMINDERS+=("--cwd / --prefix 等のオプションでパスを指定せず、cd でディレクトリ移動してから実行してください。")
fi

if [[ ${#REMINDERS[@]} -gt 0 ]]; then
  MSG=$(printf '%s\n' "${REMINDERS[@]}")
  jq -n --arg msg "$MSG" -f /dev/stdin <<'JQ'
{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $msg}}
JQ
fi

exit 0
