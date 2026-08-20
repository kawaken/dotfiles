# Claude Code 設定

## ディレクトリ構成

```
claude/
├── CLAUDE.md        # 共通指示（シンボリックリンク必要）
├── commands/        # カスタムコマンド（シンボリックリンク必要）
├── skills/          # スキル定義（シンボリックリンク必要）
└── statusline.sh    # ステータスライン表示スクリプト（settings.json で絶対パス参照）
```

## シンボリックリンクが必要なもの

Claude Code が `~/.claude/` から読み込むため、シンボリックリンクが必要:

- `~/.claude/CLAUDE.md` → `dotfiles/claude/CLAUDE.md`
- `~/.claude/commands/` → `dotfiles/claude/commands/`
- `~/.claude/skills/` → `dotfiles/claude/skills/`

## settings.json

`claude/settings.base.json` がベーステンプレート。どのマシンでも通用する汎用設定だけを置く。
マシン固有の設定（ローカルにしか無いツールのパス等）や業務固有の設定（社内 CLI、業務アカウント前提の
MCP、組織名を含む設定等）は base に入れず、`~/.claude/settings.json` 側にだけ持つ。
このリポジトリは公開されているため、後者を base に含めない点は特に重要。

セットアップ時に `~/.claude/settings.json` へ反映する:

```
# 新規: そのままコピー
cp ~/dotfiles/claude/settings.base.json ~/.claude/settings.json
```

既存の `~/.claude/settings.json` がある場合は、`jq -s '.[0] * .[1]'` のような機械的マージは使わない。
`*` 演算子は配列（`permissions.allow`/`deny` など）を丸ごと後勝ちで上書きしてしまい、既存側にだけ
追加していた許可項目が消える。以下の手順で、差分を確認したうえで手動で反映する:

```
diff ~/.claude/settings.json ~/dotfiles/claude/settings.base.json
```

- 配列のキー: base 側にあって既存側に無い項目だけを追記する（既存側にしかない項目は消さない）
- base に無いキー: 既存側をそのまま残す
- base にあるキー: base 側の値を採用する

プロジェクト固有の設定（MCP、プラグイン等）は各プロジェクトの `.claude/settings.local.json` で管理する。
