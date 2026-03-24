#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# $() コマンド置換をブロック（複数のBashステップに分割すべき）
if echo "$COMMAND" | grep -qE '\$\('; then
  echo "Blocked: \$() コマンド置換を使わないでください。コマンドを複数のBashステップに分割してください。" >&2
  exit 2
fi

# 連続したクォート文字をブロック（'" や "' は複雑なクォーティングの兆候）
if [[ "$COMMAND" == *"'\""* ]] || [[ "$COMMAND" == *"\"'"* ]]; then
  echo "Blocked: 連続したクォート文字 ('\" or \"') を検出しました。クォーティングを見直し、複雑なフィルターは別ファイルに書いてください。" >&2
  exit 2
fi

# 空クォート + ダッシュをブロック（フラグ偽装によるバリデーション回避の防止）
if [[ "$COMMAND" == *'""-'* ]] || [[ "$COMMAND" == *"''-"* ]]; then
  echo "Blocked: 空のクォートの後にダッシュを検出しました。フラグを直接記述してください。" >&2
  exit 2
fi

# cd と他コマンドのチェインをブロック（cd は単独のBash呼び出しで実行すべき）
if echo "$COMMAND" | grep -qE 'cd\s+.*&&|cd\s+.*;'; then
  echo "Blocked: cd は単独のBash呼び出しで実行してください。&& や ; で他のコマンドとチェインしないでください。" >&2
  exit 2
fi

# git 書き込みコマンドのチェインをブロック（各 git 操作は単独のBash呼び出しで実行すべき）
if echo "$COMMAND" | grep -qE 'git\s+(add|commit|push|reset|rebase|merge|rm|mv|stash).*&&.*git'; then
  echo "Blocked: git の書き込み操作を && でチェインしないでください。各 git コマンドは別々のBash呼び出しで実行してください。" >&2
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

# コマンド自体がフルパス（/ で始まる）での実行をブロック（cd してから実行すべき）
if echo "$COMMAND" | grep -qE '^/'; then
  echo "Blocked: コマンドをフルパスで実行しないでください。cd でディレクトリ移動してから実行してください。" >&2
  exit 2
fi

# python3 -m json.tool をブロックし jq empty を案内
if echo "$COMMAND" | grep -qE 'python3?\s+-m\s+json\.tool'; then
  echo "Blocked: JSON検証には jq empty を使ってください（例: jq empty file.json）。" >&2
  exit 2
fi

# 専用ツールで代替可能なコマンドをブロック（Bash ではなく Grep/Glob/Read/Edit ツールを使うべき）
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
# パイプ経由の grep / rg もブロック（例: some_cmd | grep pattern）
if echo "$COMMAND" | grep -qE '\|\s*(grep|rg|egrep|fgrep)\b'; then
  echo "Blocked: パイプでの grep/rg は Grep ツールを使ってください。" >&2
  exit 2
fi
# パイプ経由の head / tail もブロック（例: some_cmd | head -5）
if echo "$COMMAND" | grep -qE '\|\s*(head|tail)\b'; then
  echo "Blocked: パイプでの head/tail は Read ツールまたは head_limit パラメータを使ってください。" >&2
  exit 2
fi

# パイプ経由のテキスト加工コマンドをブロック（専用ツールの結果をClaude側で処理すべき）
if echo "$COMMAND" | grep -qE '\|\s*(xargs|wc|sort|uniq|cut|tr)\b'; then
  echo "Blocked: パイプでの xargs/wc/sort/uniq/cut/tr は避けてください。専用ツール（Glob/Grep/Read）で取得した結果をClaude側で処理してください。" >&2
  exit 2
fi
# sh -c / bash -c のサブシェル実行をブロック（コマンドを個別のBash呼び出しに分割すべき）
if echo "$COMMAND" | grep -qE '\b(sh|bash)\s+-c\b'; then
  echo "Blocked: sh -c / bash -c は避けてください。コマンドを個別のBash呼び出しに分割してください。" >&2
  exit 2
fi

# コマンド引数にホームディレクトリの絶対パスが含まれる場合をブロック
if echo "$COMMAND" | grep -qE '/Users/[a-zA-Z0-9_]+/'; then
  echo "Blocked: コマンド引数にフルパスを使わないでください。cd でディレクトリ移動してから相対パスで実行してください。" >&2
  exit 2
fi

# 作業ディレクトリ指定オプション + 絶対パスをブロック（git -C, yarn --cwd, npm --prefix 等）
if echo "$COMMAND" | grep -qE '(-C|--cwd|--prefix|--directory)\s+/'; then
  echo "Blocked: -C / --cwd / --prefix 等のオプションでフルパスを指定しないでください。cd でディレクトリ移動してから実行してください。" >&2
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
