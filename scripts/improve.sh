#!/usr/bin/env zsh
#
# 改善分析スクリプト
# facets + friction-log を分析し、改善提案をdraft PRとして作成する
#
# 使い方:
#   ./scripts/improve.sh          # 最近7日分を分析
#   ./scripts/improve.sh --days 14  # 最近14日分を分析

setopt errexit

DOTFILES_DIR="${0:A:h:h}"
FACETS_DIR="$HOME/.claude/usage-data/facets"
FRICTION_LOG="$HOME/.claude/friction-log.md"
SKILL_FILE="$DOTFILES_DIR/claude/skills/improve/SKILL.md"
DAYS=7

while [[ $# -gt 0 ]]; do
  case $1 in
    --days) DAYS=$2; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# facets を収集（最近N日分、最大30件）
collect_facets() {
  local cutoff
  cutoff=$(date -v "-${DAYS}d" +%s 2>/dev/null || date -d "-${DAYS} days" +%s)
  local result=""
  local count=0

  if [[ ! -d "$FACETS_DIR" ]]; then
    echo "(facetsデータなし)"
    return
  fi

  local file
  for file in "$FACETS_DIR"/*.json(Om[1,30]); do
    [[ -f "$file" ]] || continue
    local mtime
    mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file")
    if (( mtime >= cutoff )); then
      result+="$(cat "$file")\n"
      (( count++ ))
    fi
  done

  if [[ -z "$result" ]]; then
    echo "(対象期間内のfacetsデータなし)"
  else
    echo "=== facets ($count sessions) ===\n$result"
  fi
}

# プロンプトを構築
build_prompt() {
  local skill_instructions
  skill_instructions=$(cat "$SKILL_FILE")

  echo "以下のデータを使って改善分析を行ってください。\n\n"
  echo "## スキル指示\n$skill_instructions\n\n"
  echo "## 収集データ\n"

  if [[ -f "$FRICTION_LOG" ]]; then
    echo "### friction-log\n$(cat "$FRICTION_LOG")\n\n"
  fi

  echo "### facets\n$(collect_facets)"
}

# メイン処理
main() {
  echo "改善分析を開始します（過去${DAYS}日分）..."

  # 分析実行
  local analysis
  analysis=$(build_prompt | claude --print --model sonnet)

  if [[ -z "$analysis" ]]; then
    echo "分析結果が空です"
    exit 1
  fi

  # ブランチ作成
  local branch
  branch="improve/$(date +%Y%m%d)"
  cd "$DOTFILES_DIR"
  git checkout -b "$branch" 2>/dev/null || git checkout "$branch"

  # 分析結果をファイルに書く
  local outfile="claude/improve-$(date +%Y%m%d).md"
  printf "# 改善提案 %s\n\n%s\n" "$(date +%Y-%m-%d)" "$analysis" > "$outfile"
  echo "分析結果: $outfile"

  # コミット・プッシュ
  git add "$outfile"
  git commit -m "improve: $(date +%Y-%m-%d) 改善分析"
  git push -u origin "$branch"

  # draft PR作成
  gh pr create \
    --draft \
    --title "improve: $(date +%Y-%m-%d) 改善提案" \
    --body "$(cat "$outfile")" \
    --base main

  echo "Draft PRを作成しました"
}

main
