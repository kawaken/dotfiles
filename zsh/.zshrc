# オプション
# http://zsh.sourceforge.net/Doc/Release/Options.html
# Changing Directories
setopt AUTO_CD                       # ディレクトリ名だけで移動
setopt AUTO_PUSHD                    # 自動でpushdする、cdの履歴表示
setopt CD_SILENT                     # `cd -` の時にディレクトリを非表示
setopt PUSHD_SILENT                  # pushd, popd でディレクトリを非表示
setopt PUSHD_IGNORE_DUPS             # 重複ディレクトリを無視
# Completion
unsetopt AUTO_REMOVE_SLASH           # ディレクトリの末尾/を勝手に消さない
unsetopt LIST_BEEP                   # beep音を出さない
setopt LIST_PACKED                   # 表示を詰め込む
# Expansion and Globbing
setopt GLOB_STAR_SHORT               # **/* を ** と書ける
setopt MAGIC_EQUAL_SUBST             # =の後も補完する
# History
setopt EXTENDED_HISTORY              # 実行時刻を記録
unsetopt HIST_BEEP                   # beep音を出さない
setopt HIST_IGNORE_DUPS              # 直前のコマンドと重複を無視
setopt HIST_IGNORE_SPACE             # スペース開始を無視
setopt HIST_NO_STORE                 # historyコマンドは無視
setopt HIST_VERIFY                   # 履歴から直接実行しない
setopt SHARE_HISTORY                 # 履歴を共有
# Input/Output
unsetopt FLOW_CONTROL                # フローコントロールを無効(Ctrl+Sが使える)
setopt IGNORE_EOF                    # Ctrl+Dでログアウトしない
setopt INTERACTIVE_COMMENTS          # #以降をコメントとみなす
setopt PRINT_EIGHT_BIT               # 補完時の日本語表示
#setopt PRINT_EXIT_VALUE              # 0以外の終了コードを表示
setopt RM_STAR_SILENT                # rm * で削除確認しない(-iを付けてるので大丈夫)
# Job Control
REPORTTIME=30                        # 30秒以上でtimeを出力
unsetopt BG_NICE                     # バックグラウンドジョブの優先度を下げない
setopt LONG_LIST_JOBS                # jobs -l をデフォルト
# Prompting
setopt PROMPT_SUBST                  # 実行時の変数展開
setopt TRANSIENT_RPROMPT             # 最後のRPROMPTだけ表示
# Zle
unsetopt BEEP                        # beep音を出さない

# キーバインド
bindkey -e

# 履歴
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
HISTTIMEFORMAT="[%Y/%M/%D %H:%M:%S] "

function _source() {
  [ -n "$1" -a -f "$1" ] && . "$1"
}

# OS依存のファイル
_source $ZDOTDIR/.zshrc_$(uname)

# source plugins
for file in $ZDOTDIR/plugins/*(.); do
  _source $file
done

# 端末依存のファイル
_source $HOME/.zshrc_local

# hook を有効にする
autoload -Uz add-zsh-hook

# プロンプト設定
# シェルの階層が増えると > を表示する
function _update_shlvl() {
  if [ $SHLVL -gt 1 ]; then
    local bc
    bc=$(($SHLVL - 1))
    prompt="$(printf '%.1s' '>'{1..$bc})$prompt"
  fi

  echo "$prompt"
}

function _update_prompt() {
  # PWDを黄色で
  local full_path="%F{yellow}%d%f"
  # vcs_infoのメッセージ
  local vcs_info_msg=$(_update_vcs_info_msg)
  # shellの深さ
  local shlvl=$(_update_shlvl)
  # 直前実行したコマンドの結果
  local prev_result="%(?,,%F{red}!!!%f )"
  # user
  local user="%n"
  # jobがあればセパレーターをマゼンタに
  local sep="%(1j,%F{magenta}%#%f,%#)"
  # workonの状態
  local work_mode=$(_update_workon)

  PROMPT="
${full_path}${vcs_info_msg} ${work_mode}
${user} ${sep} ${prev_result}"
  RPROMPT="%D{%Y-%m-%d %H:%M:%S}"
}
add-zsh-hook precmd _update_prompt

# ZDOTDIRを前提にしているので、HOMEのrcファイルも読み込む
_source $HOME/.zshrc

# 最後に実行する必要がある
source_zsh-syntax-highlighting
