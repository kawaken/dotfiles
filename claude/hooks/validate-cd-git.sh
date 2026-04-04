#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command')

# cd と他コマンドのチェインをブロック（cd は単独のBash呼び出しで実行すべき）
if echo "$COMMAND" | grep -qE 'cd\s+.*&&|cd\s+.*;'; then
  echo "Blocked: cd は単独のBash呼び出しで実行してください。&& や ; で他のコマンドとチェインしないでください。" >&2
  exit 2
fi

# cd にフルパスを使用するのをブロック（同一ワークスペース内は相対パスで移動すべき）
if echo "$COMMAND" | grep -qE '\bcd\s+/'; then
  CD_DEST=$(echo "$COMMAND" | grep -oE 'cd[[:space:]]+/[^[:space:]]+' | head -1 | sed 's/cd[[:space:]]*//')
  if [[ -n "$CD_DEST" && "$CD_DEST" == "${PWD}"* ]]; then
    echo "Blocked: 同じワークスペース内での cd はフルパスではなく相対パスを使ってください。" >&2
    exit 2
  fi
fi

# git add → git commit のチェインは明示的に許可
if echo "$COMMAND" | grep -qE '^git add [^&]+ && git commit( [^&]+)?$'; then
  exit 0
fi

# git コマンドのチェインをブロック
if echo "$COMMAND" | grep -qE '\bgit\b.*&&.*\bgit\b'; then
  echo "Blocked: git の操作を && でチェインしないでください。各 git コマンドは別々のBash呼び出しで実行してください。" >&2
  exit 2
fi

# git -C によるディレクトリ指定をブロック（任意ディレクトリ操作を防ぐ）
if echo "$COMMAND" | grep -qE '\bgit\b.*\s-C\s'; then
  echo "Blocked: git -C でディレクトリを指定しないでください。cd でディレクトリ移動してから実行してください。" >&2
  exit 2
fi

# 作業ディレクトリ指定オプション + パスをブロック（yarn --cwd, npm --prefix 等）
if echo "$COMMAND" | grep -qE '(--cwd|--prefix|--directory)\s+[/~]'; then
  echo "Blocked: --cwd / --prefix 等のオプションでパスを指定しないでください。cd でディレクトリ移動してから実行してください。" >&2
  exit 2
fi

# git push --force をブロック（--force-with-lease は許可）
if echo "$COMMAND" | grep -qE 'git\s+push\b.*(\s--force([[:space:]]|$)|\s-f\b)'; then
  echo "Blocked: git push --force / -f は禁止です。--force-with-lease を使うか、通常の git push を使ってください。" >&2
  exit 2
fi

exit 0
