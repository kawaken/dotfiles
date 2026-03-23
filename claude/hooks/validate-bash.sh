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
