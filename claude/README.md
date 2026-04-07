# Claude Code 設定

## ディレクトリ構成

```
claude/
├── CLAUDE.md        # 共通指示（シンボリックリンク必要）
├── commands/        # カスタムコマンド（シンボリックリンク必要）
├── skills/          # スキル定義（シンボリックリンク必要）
├── hooks/           # フックスクリプト（settings.json で絶対パス参照）
└── statusline.sh    # ステータスライン表示スクリプト（settings.json で絶対パス参照）
```

## シンボリックリンクが必要なもの

Claude Code が `~/.claude/` から読み込むため、シンボリックリンクが必要:

- `~/.claude/CLAUDE.md` → `dotfiles/claude/CLAUDE.md`
- `~/.claude/commands/` → `dotfiles/claude/commands/`
- `~/.claude/skills/` → `dotfiles/claude/skills/`

## settings.json

`claude/settings.base.json` がベーステンプレート。permissions、hooks、statusLine を含む。

セットアップ時に `~/.claude/settings.json` へ反映する:

```
# 新規: そのままコピー
cp ~/dotfiles/claude/settings.base.json ~/.claude/settings.json

# 既存: ベースの内容をマージ（ベース側が優先）
jq -s '.[0] * .[1]' ~/.claude/settings.json ~/dotfiles/claude/settings.base.json > ~/.claude/settings.json.tmp && mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

プロジェクト固有の設定（MCP、プラグイン等）は各プロジェクトの `.claude/settings.local.json` で管理する。
