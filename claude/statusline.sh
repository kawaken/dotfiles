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

# ゲージ: 0-80%はブロック1文字、80%超は2桁数値
pct_gauge() {
  local pct=$1
  if [[ $pct -gt 80 ]]; then
    echo "$pct"
  else
    local blocks=( ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ )
    local idx=$(( pct * 8 / 100 ))
    [[ $idx -gt 7 ]] && idx=7
    echo "${blocks[$((idx + 1))]}"
  fi
}

# モデル名: "Opus 4.8 (1M context)" → "Op4.8:1m"
display_name=$(echo "$input" | jq -r '.model.display_name // "unknown"')
model_base=${display_name%%" ("*}      # "Opus 4.8"
family=${model_base%% *}               # "Opus"
version=${model_base#* }               # "4.8"
[[ "$version" == "$model_base" ]] && version=""

case $family in
  Haiku*) family="Hi" ;;
  Sonnet*) family="So" ;;
  Opus*) family="Op" ;;
esac

# コンテキスト種別（"(1M context)" などの括弧内を簡略表記）
ctx_tag=""
if [[ "$display_name" == *"("* ]]; then
  ctx_paren=${display_name#*\(}         # "1M context)"
  ctx_paren=${ctx_paren%%\)*}           # "1M context"
  ctx_tag=${(L)ctx_paren%% *}           # "1m"
fi

model="${family}${version}"             # "op4.8"
[[ -n "$ctx_tag" ]] && model+=":$ctx_tag" # "op4.8:1m"

# コンテキスト使用率（事前計算済みの値を使用）
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | floor')

# rate_limits（5時間・7日ウィンドウ）
rl_5h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | if . then floor else empty end')
rl_7d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | if . then floor else empty end')

# セッション名（--name / /rename で設定した名前、なければAI生成タイトル）
session_name=$(echo "$input" | jq -r '.session_name // empty')

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

# gitリポジトリ情報（session_idキーのキャッシュで重いgit呼び出しを間引く）
session_id=$(echo "$input" | jq -r '.session_id // ""')
worktree_name=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
cache_file="/tmp/claude-statusline-git-${session_id}"
cache_ttl=5

cache_stale() {
  [[ ! -f "$cache_file" ]] && return 0
  local mtime
  mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)
  (( $(date +%s) - mtime > cache_ttl ))
}

if cache_stale; then
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    repo_name=$(basename "$(git rev-parse --show-toplevel)")
    branch=$(git branch --show-current 2>/dev/null || echo "detached")

    has_upstream=0
    ahead=0
    behind=0
    if git rev-parse --verify "@{upstream}" &>/dev/null; then
      has_upstream=1
      ahead=$(git rev-list --count "@{upstream}..HEAD" 2>/dev/null)
      behind=$(git rev-list --count "HEAD..@{upstream}" 2>/dev/null)
    fi

    read staged modified untracked conflicted <<< $(
      git --no-optional-locks status --porcelain 2>/dev/null | awk '{
        x = substr($0,1,1); y = substr($0,2,1)
        if (x=="U"||y=="U"||(x=="A"&&y=="A")||(x=="D"&&y=="D")) c++
        else if (x!=" "&&x!="?") s++
        if (y!=" "&&x!="?"&&y!="U") m++
        if (x=="?") u++
      } END { print s+0, m+0, u+0, c+0 }'
    )

    print -r -- "${repo_name}|${branch}|${has_upstream}|${ahead}|${behind}|${staged}|${modified}|${untracked}|${conflicted}" > "$cache_file"
  else
    print -r -- "" > "$cache_file"
  fi
fi

git_info=""
IFS='|' read repo_name branch has_upstream ahead behind staged modified untracked conflicted < "$cache_file"

if [[ -n "$repo_name" ]]; then
  upstream_info=""
  if [[ $has_upstream -eq 1 ]]; then
    branch_color=$C_BLUE
    [[ $ahead -gt 0 ]] && upstream_info+=":${C_GREEN}⇡$ahead${C_RESET}"
    [[ $behind -gt 0 ]] && upstream_info+=":${C_RED}⇣$behind${C_RESET}"
  else
    branch_color=$C_ORANGE
  fi

  git_status=""
  [[ $conflicted -gt 0 ]] && git_status+="${C_RED}!$conflicted${C_RESET}"
  [[ $staged -gt 0 ]] && git_status+="${C_GREEN}+$staged${C_RESET}"
  [[ $modified -gt 0 ]] && git_status+="${C_RED}*$modified${C_RESET}"
  [[ $untracked -gt 0 ]] && git_status+="${C_YELLOW}?$untracked${C_RESET}"

  worktree_info=""
  [[ -n "$worktree_name" ]] && worktree_info=" ${C_WHITE}(${C_RESET}${worktree_name}${C_WHITE})${C_RESET}"

  git_info="${C_YELLOW}${repo_name}${C_RESET} ${C_WHITE}[${C_RESET}${branch_color}${branch}${C_RESET}${upstream_info}${C_WHITE}]${C_RESET}${worktree_info}"
  [[ -n "$git_status" ]] && git_info+=" ${git_status}"
fi

# ゲージ表示（TrueColor + ブロック文字 + ブレイル）
ctx_color=$(pct_color $context_pct)
ctx_g=$(pct_gauge $context_pct)
gauge="C:${ctx_color}${ctx_g}${C_RESET}"

if [[ -n "$rl_5h_pct" ]]; then
  fh_color=$(pct_color $rl_5h_pct)
  fh_g=$(pct_gauge $rl_5h_pct)
  gauge+=" 5:${fh_color}${fh_g}${C_RESET}"
fi

if [[ -n "$rl_7d_pct" ]]; then
  sd_color=$(pct_color $rl_7d_pct)
  sd_g=$(pct_gauge $rl_7d_pct)
  gauge+=" 7:${sd_color}${sd_g}${C_RESET}"
fi

# 出力: repo [branch] status :: [model] ctx:▃ 5h:▅ 7d:▂ · session_name / todo
output=""
[[ -n "$git_info" ]] && output+="${git_info}"
output+=" [${model}] ${gauge}"
[[ -n "$session_name" ]] && output+=" · ${session_name}"
[[ -n "$todo_display" ]] && output+=" / ${todo_display}"

printf '%s' "$output"
