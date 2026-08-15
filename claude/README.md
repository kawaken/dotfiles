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

`claude/settings.base.json` がベーステンプレート。permissions、statusLine を含む。

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

- `permissions.allow` / `permissions.deny`: base 側にあって既存側に無い項目だけを既存の配列に追記する
  （既存側にしかない項目は残す）
- `hooks` など base に存在しないキー: 既存側の設定をそのまま残す
- `statusLine` など base 側の値を採用したいキー: 該当キーだけ既存側を書き換える

プロジェクト固有の設定（MCP、プラグイン等）は各プロジェクトの `.claude/settings.local.json` で管理する。
