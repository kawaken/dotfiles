#!/usr/bin/env zsh
INPUT=$(cat)
COMMAND=$(printf '%s\n' "$INPUT" | jq -r '.tool_input.command')

# コマンドが長すぎる場合をブロック（7行超はスクリプトファイルに分離すべき）
LINE_COUNT=$(echo "$COMMAND" | wc -l | tr -d ' ')
if [[ $LINE_COUNT -gt 7 ]]; then
  echo "Blocked: コマンドが長すぎます（${LINE_COUNT}行）。スクリプトファイルに書いてから実行してください。" >&2
  exit 2
fi

# /tmp/ へのアクセスをブロック（./tmp/ を使うべき）
if echo "$COMMAND" | grep -qE '(^|[[:space:]>|<])/tmp/'; then
  echo "Blocked: /tmp/ へのアクセスは禁止です。./tmp/ を使ってください（なければ mkdir -p ./tmp/ で作成）。" >&2
  exit 2
fi

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

# sh -c / bash -c のサブシェル実行をブロック（コマンドを個別のBash呼び出しに分割すべき）
if echo "$COMMAND" | grep -qE '\b(sh|bash)\s+-c\b'; then
  echo "Blocked: sh -c / bash -c は避けてください。コマンドを個別のBash呼び出しに分割してください。" >&2
  exit 2
fi

# コマンド自体がフルパス（/ で始まる）での実行をブロック（cd してから実行すべき）
if echo "$COMMAND" | grep -qE '^/'; then
  echo "Blocked: コマンドをフルパスで実行しないでください。cd でディレクトリ移動してから実行してください。" >&2
  exit 2
fi

# コマンド引数にホームディレクトリの絶対パスが含まれる場合をブロック（cd は validate-cd-git.sh で個別チェック）
if [[ "$COMMAND" != cd\ * ]] && echo "$COMMAND" | grep -qE '/Users/[a-zA-Z0-9_]+/'; then
  echo "Blocked: コマンド引数にフルパスを使わないでください。cd でディレクトリ移動してから相対パスで実行してください。" >&2
  exit 2
fi

# パイプ経由のテキスト加工コマンドをブロック（専用ツールの結果をClaude側で処理すべき）
if echo "$COMMAND" | grep -qE '\|\s*(xargs|wc|sort|uniq|cut|tr)\b'; then
  echo "Blocked: パイプでの xargs/wc/sort/uniq/cut/tr は避けてください。専用ツール（Glob/Grep/Read）で取得した結果をClaude側で処理してください。" >&2
  exit 2
fi

# jq の長いインラインフィルターをブロック（jq がコマンド中間に出る場合も対応）
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

exit 0
