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

# git 書き込みコマンドのチェインをブロック（各 git 操作は単独のBash呼び出しで実行すべき）
if echo "$COMMAND" | grep -qE 'git\s+(add|commit|push|reset|rebase|merge|rm|mv|stash).*&&.*git'; then
  echo "Blocked: git の書き込み操作を && でチェインしないでください。各 git コマンドは別々のBash呼び出しで実行してください。" >&2
  exit 2
fi

# 作業ディレクトリ指定オプション + 絶対パスをブロック（git -C, yarn --cwd, npm --prefix 等）
if echo "$COMMAND" | grep -qE '(-C|--cwd|--prefix|--directory)\s+/'; then
  echo "Blocked: -C / --cwd / --prefix 等のオプションでフルパスを指定しないでください。cd でディレクトリ移動してから実行してください。" >&2
  exit 2
fi

exit 0
