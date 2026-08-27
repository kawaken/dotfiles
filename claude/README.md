# Claude Code / Codex 設定

## ディレクトリ構成

```
claude/
├── CLAUDE.md        # Claude Code / Codex のユーザー共通指示（シンボリックリンク必要）
├── commands/        # カスタムコマンド（シンボリックリンク必要）
├── skills/          # スキル定義（シンボリックリンク必要）
├── themes/          # カスタムテーマ（シンボリックリンク必要）
└── statusline.sh    # ステータスライン表示スクリプト（settings.json で絶対パス参照）
```

## ユーザー共通指示

`CLAUDE.md` を共通の正本として、各ツールの標準ファイル名から同じ実体へリンクする。

- `~/.claude/CLAUDE.md` → `dotfiles/claude/CLAUDE.md`
- `~/.codex/AGENTS.md` → `dotfiles/claude/CLAUDE.md`

Claude Code はユーザー指示を `~/.claude/CLAUDE.md` から、Codex はグローバル指示を
`~/.codex/AGENTS.md` から読み込む。ファイル名はツールごとに異なるが、内容の重複は持たない。

このファイルには両ツールで解釈できる指示だけを置く。Claude Code のコマンド、スキル、設定などは
それぞれの専用ファイルで管理する。

## シンボリックリンクが必要なもの

Claude Code 固有のコマンド、スキル、テーマを `~/.claude/` から読み込むため、シンボリックリンクが必要:

- `~/.claude/commands/` → `dotfiles/claude/commands/`
- `~/.claude/skills/` → `dotfiles/claude/skills/`
- `~/.claude/themes/` → `dotfiles/claude/themes/`

テーマは `settings.json` の `theme` に `custom:<ファイル名>` の形式で指定する。
`themes/blue.json` なら `"theme": "custom:blue"`。

## settings.json

`claude/settings.base.json` がベーステンプレート。どのマシンでも通用する汎用設定だけを置く。
マシン固有の設定（ローカルにしか無いツールのパス等）や業務固有の設定（社内 CLI、業務アカウント前提の
MCP、組織名を含む設定等）は base に入れず、`~/.claude/settings.json` 側にだけ持つ。
このリポジトリは公開されているため、後者を base に含めない点は特に重要。

セットアップ時に `~/.claude/settings.json` へ反映する。

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

## gw との連携

`gw` に Claude Code / Codex のセッション状態を観測させる場合は、既存の hooks 設定を確認してから、`gw` が出力する設定を手動で追加する。`gw` は既存設定を自動変更しない。

```sh
gw guide agent-hook claude
gw guide agent-hook codex
```

Claude Code の設定先は `~/.claude/settings.json`、Codex の設定先は `~/.codex/hooks.json` または `~/.codex/config.toml`。セッション状態は `~/.local/state/gw/sessions.json` に保存され、リポジトリ内には独自メタデータを書き込まない。
