# OS依存のファイル
[ -f $ZDOTDIR/.zshrc_$(uname) ] && . $ZDOTDIR/.zshrc_$(uname)
# エイリアス
[ -f $ZDOTDIR/aliases ] && . $ZDOTDIR/aliases

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
setopt PRINT_EXIT_VALUE              # 0以外の終了コードを表示
setopt RM_STAR_SILENT                # rm * で削除確認しない(-iを付けてるので大丈夫)
# Job Control
unsetopt BG_NICE                     # バックグラウンドジョブの優先度を下げない
setopt LONG_LIST_JOBS                # jobs -l をデフォルト
# Prompting
setopt PROMPT_SUBST                  # 実行時の変数展開
setopt TRANSIENT_RPROMPT             # 最後のRPROMPTだけ表示
# Zle
unsetopt BEEP                        # beep音を出さない

# キーバインド
bindkey -e

