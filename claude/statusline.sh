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

# TrueColor グラデーション（緑→黄→赤）
pct_color() {
  local pct=$1
  local r g
  if [[ $pct -le 50 ]]; then
    r=$((pct * 5))
    g=200
  else
    r=255
    g=$(( (100 - pct) * 4 ))
  fi
  printf '\e[38;2;%d;%d;0m' $r $g
}

# ブロック文字ゲージ
pct_block() {
  local pct=$1
  local blocks=( ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ )
  local idx=$(( pct * 8 / 100 ))
  [[ $idx -gt 7 ]] && idx=7
  echo "${blocks[$((idx + 1))]}"
}

# モデル名
model=$(echo "$input" | jq -r '.model.display_name // "unknown" | split(" (")[0]')

# コンテキスト使用率
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
current_usage=$(echo "$input" | jq -r '.context_window.current_usage // {}')
current_tokens=$(echo "$current_usage" | jq -r '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
if [[ $context_size -gt 0 ]]; then
  context_pct=$((current_tokens * 100 / context_size))
else
  context_pct=0
fi

# rate_limits（5時間・7日ウィンドウ）
rl_5h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | if . then floor else empty end')
rl_7d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | if . then floor else empty end')

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

  read staged modified untracked conflicted <<< $(
    git status --porcelain 2>/dev/null | awk '{
      x = substr($0,1,1); y = substr($0,2,1)
      if (x=="U"||y=="U"||(x=="A"&&y=="A")||(x=="D"&&y=="D")) c++
      else if (x!=" "&&x!="?") s++
      if (y!=" "&&x!="?"&&y!="U") m++
      if (x=="?") u++
    } END { print s+0, m+0, u+0, c+0 }'
  )

  git_status=""
  [[ $conflicted -gt 0 ]] && git_status+="${C_RED}!$conflicted${C_RESET}"
  [[ $staged -gt 0 ]] && git_status+="${C_GREEN}+$staged${C_RESET}"
  [[ $modified -gt 0 ]] && git_status+="${C_RED}*$modified${C_RESET}"
  [[ $untracked -gt 0 ]] && git_status+="${C_YELLOW}?$untracked${C_RESET}"

  git_info="${C_YELLOW}${repo_name}${C_RESET} ${C_WHITE}[${C_RESET}${branch_color}${branch}${C_RESET}${upstream_info}${C_WHITE}]${C_RESET}"
  [[ -n "$git_status" ]] && git_info+=" ${git_status}"
fi

# ゲージ表示（TrueColor + ブロック文字）
ctx_color=$(pct_color $context_pct)
ctx_block=$(pct_block $context_pct)
gauge="C:${ctx_color}${ctx_block}${C_RESET}"

if [[ -n "$rl_5h_pct" ]]; then
  fh_color=$(pct_color $rl_5h_pct)
  fh_block=$(pct_block $rl_5h_pct)
  gauge+=" 5:${fh_color}${fh_block}${C_RESET}"
fi

if [[ -n "$rl_7d_pct" ]]; then
  sd_color=$(pct_color $rl_7d_pct)
  sd_block=$(pct_block $rl_7d_pct)
  gauge+=" 7:${sd_color}${sd_block}${C_RESET}"
fi

# 出力: repo [branch] status :: [model] ctx:▃ 5h:▅ 7d:▂ / todo
output=""
[[ -n "$git_info" ]] && output+="${git_info}"
output+=" [${model}] ${gauge}"
[[ -n "$todo_display" ]] && output+=" / ${todo_display}"

printf '%s' "$output"
