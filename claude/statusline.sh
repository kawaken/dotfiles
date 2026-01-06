#!/usr/bin/env zsh
input=$(cat)

# ANSIカラー（zshのPROMPTと同等）
C_RESET=$'\e[0m'
C_WHITE=$'\e[37m'        # 括弧
C_BLUE=$'\e[38;5;69m'    # ブランチ名（upstream有）
C_ORANGE=$'\e[38;5;202m' # ブランチ名（upstream無）
C_GREEN=$'\e[32m'        # staged (+), ahead (⇡)
C_RED=$'\e[31m'          # modified (*), behind (⇣), conflicted (!)
C_YELLOW=$'\e[33m'       # untracked (?)

# モデル名
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')

# コンテキスト使用率（total_input_tokens を使用）
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
if [[ $context_size -gt 0 ]]; then
  context_pct=$((input_tokens * 100 / context_size))
else
  context_pct=0
fi

# TODO情報（transcript_pathからTodoWriteの最新を取得）
todo_display=""
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')
if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
  todo_json=$(grep 'TodoWrite' "$transcript_path" | tail -1 | jq -r '.message.content[]? | select(.type == "tool_use" and .name == "TodoWrite") | .input.todos // empty' 2>/dev/null)
  if [[ -n "$todo_json" ]]; then
    total=$(echo "$todo_json" | jq 'length')
    completed=$(echo "$todo_json" | jq '[.[] | select(.status == "completed")] | length')
    in_progress=$(echo "$todo_json" | jq -r '.[] | select(.status == "in_progress") | .activeForm // .content' | head -1)

    if [[ -n "$in_progress" ]]; then
      [[ ${#in_progress} -gt 30 ]] && in_progress="${in_progress:0:27}..."
      todo_display="${in_progress} (${completed}/${total})"
    fi
  fi
fi

# gitリポジトリ情報（zshと同等のカラー・フォーマット）
git_info=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  repo_name=$(basename "$(git rev-parse --show-toplevel)")
  branch=$(git branch --show-current 2>/dev/null || echo "detached")

  # upstream確認とahead/behind
  upstream_info=""
  if git rev-parse --verify "@{upstream}" &>/dev/null; then
    branch_color=$C_BLUE
    ahead=$(git rev-list "@{upstream}..HEAD" 2>/dev/null | wc -l | tr -d ' ')
    behind=$(git rev-list "HEAD..@{upstream}" 2>/dev/null | wc -l | tr -d ' ')
    [[ $ahead -gt 0 ]] && upstream_info+=":${C_GREEN}⇡$ahead${C_RESET}"
    [[ $behind -gt 0 ]] && upstream_info+=":${C_RED}⇣$behind${C_RESET}"
  else
    branch_color=$C_ORANGE
  fi

  # ファイル状態
  staged=$(git diff --staged --name-only 2>/dev/null | wc -l | tr -d ' ')
  modified=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
  conflicted=$(git diff --name-only --diff-filter=U 2>/dev/null | wc -l | tr -d ' ')

  # git status（括弧の外）
  git_status=""
  [[ $conflicted -gt 0 ]] && git_status+="${C_RED}!$conflicted${C_RESET}"
  [[ $staged -gt 0 ]] && git_status+="${C_GREEN}+$staged${C_RESET}"
  [[ $modified -gt 0 ]] && git_status+="${C_RED}*$modified${C_RESET}"
  [[ $untracked -gt 0 ]] && git_status+="${C_YELLOW}?$untracked${C_RESET}"

  # フォーマット: repo [branch:ahead:behind] status
  git_info="${C_YELLOW}${repo_name}${C_RESET} ${C_WHITE}[${C_RESET}${branch_color}${branch}${C_RESET}${upstream_info}${C_WHITE}]${C_RESET}"
  [[ -n "$git_status" ]] && git_info+=" ${git_status}"
fi

# コンテキスト使用量の色（閾値で変更）
if [[ $context_pct -ge 80 ]]; then
  context_color=$C_RED
elif [[ $context_pct -ge 50 ]]; then
  context_color=$C_YELLOW
else
  context_color=$C_WHITE
fi

# 出力を構築: dotfiles [main] ?1 :: [Opus 4.5] 23% / taskname (n/m)
output=""
[[ -n "$git_info" ]] && output+="${git_info}"
output+=" :: [${model}] ${context_color}${context_pct}%${C_RESET}"
[[ -n "$todo_display" ]] && output+=" / ${todo_display}"

printf '%s' "$output"
