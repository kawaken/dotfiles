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

## settings.json への追記が必要なもの

`~/.claude/settings.json` に絶対パスで設定を追記する（README.md の install セクション参照）:

- `hooks`: `claude/hooks/` 配下のスクリプト
- `statusLine`: `claude/statusline.sh`
