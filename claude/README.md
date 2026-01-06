# Claude Code 設定

## ディレクトリ構成

```
claude/
├── CLAUDE.md        # 共通指示（シンボリックリンク必要）
├── commands/        # カスタムコマンド（シンボリックリンク必要）
└── hooks/           # フックスクリプト
```

## シンボリックリンクが必要なもの

Claude Code が `~/.claude/` から読み込むため、シンボリックリンクが必要:

- `~/.claude/CLAUDE.md` → `dotfiles/claude/CLAUDE.md`
- `~/.claude/commands/` → `dotfiles/claude/commands/`
