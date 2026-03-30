# CLAUDE.md

dotfilesリポジトリ。zsh設定、Git設定、カスタムツール、Claude Code設定を管理する。

## 構成

- **zsh/**: zshの設定とプラグインシステム
- **git/**: Git設定、カスタムコマンド（git-*）、zsh関数
- **gw/**: Git Worktreeヘルパー（サブモジュール）
- **claude/**: Claude Code設定（~/.claude/ へシンボリックリンク）
- **ghostty/**: ターミナル設定

## 規約

### シェルスクリプト
- zshを使う（`#!/usr/bin/env zsh`）。bashは使わない
- Perl不可
- `while read` パイプ、`while` ループを避ける
- 検索は `rg` を使う
- `status` を変数名にしない（zshの予約変数）
- `local` 宣言はループの外で行い、ループ内では代入のみ
- 不要な出力・コメント・冗長な実装を避ける

### プラグイン追加
- `zsh/plugins/` に個別ファイルで追加。名前はアンダースコア区切り
- Git関連関数は `git/rc/` に配置（gitプラグインが自動読み込み）

### カスタムGitコマンド
- `git/bin/` に `git-` プレフィクスで配置。zsh shebang、実行権限付与
