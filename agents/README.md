# Claude Code / Codex 設定

## ディレクトリ構成

```
agents/
├── AGENTS.md             # Claude Code / Codex のユーザー共通指示
├── skills/               # Claude Code / Codex の共有スキル
├── claude/               # Claude Code 専用
│   ├── commands/         # カスタムコマンド
│   ├── settings.base.json
│   ├── statusline.sh
│   └── themes/           # カスタムテーマ
└── codex/                # Codex 専用（現在は置き場のみ）
```

## ユーザー共通指示

`AGENTS.md` を共通の正本として、各ツールの標準ファイル名から同じ実体へリンクする。

- `~/.claude/CLAUDE.md` → `dotfiles/agents/AGENTS.md`
- `~/.codex/AGENTS.md` → `dotfiles/agents/AGENTS.md`

Claude Code はユーザー指示を `~/.claude/CLAUDE.md` から、Codex はグローバル指示を
`~/.codex/AGENTS.md` から読み込む。ファイル名はツールごとに異なるが、内容の重複は持たない。

このファイルには両ツールで解釈できる指示だけを置く。Claude Code / Codex の固有設定はそれぞれの
専用ディレクトリで管理する。

## スキル

共有スキルは、両ツールのスキルディレクトリにスキル単位でリンクする。こうすると共有スキルと
ツール固有スキルを同じ場所へ混ぜずに済む。

共有スキルは `agents/skills/`、Claude Code 専用スキルは `agents/claude/skills/`、Codex 専用スキルは
`agents/codex/skills/` に置く。`SKILL.md` は Agent Skills の形式に合わせ、共有スキルでは特定ツールの
API名やツール名を前提にしない。

## Claude Code 専用設定

Claude Code 固有のコマンド、テーマ、statusline、設定を `~/.claude/` から読み込む:

- `~/.claude/commands/` → `dotfiles/agents/claude/commands/`
- `~/.claude/skills/` → 共有スキルと `dotfiles/agents/claude/skills/` の各スキル
- `~/.claude/themes/` → `dotfiles/agents/claude/themes/`

テーマは `settings.json` の `theme` に `custom:<ファイル名>` の形式で指定する。
`themes/blue.json` なら `"theme": "custom:blue"`。

### settings.json

`agents/claude/settings.base.json` がベーステンプレート。どのマシンでも通用する汎用設定だけを置く。
マシン固有の設定（ローカルにしか無いツールのパス等）や業務固有の設定（社内 CLI、業務アカウント前提の
MCP、組織名を含む設定等）は base に入れず、`~/.claude/settings.json` 側にだけ持つ。
このリポジトリは公開されているため、後者を base に含めない点は特に重要。

セットアップ時に `~/.claude/settings.json` へ反映する。

```
# 新規: そのままコピー
cp ~/dotfiles/agents/claude/settings.base.json ~/.claude/settings.json
```

既存の `~/.claude/settings.json` がある場合は、`jq -s '.[0] * .[1]'` のような機械的マージは使わない。
`*` 演算子は配列（`permissions.allow`/`deny` など）を丸ごと後勝ちで上書きしてしまい、既存側にだけ
追加していた許可項目が消える。以下の手順で、差分を確認したうえで手動で反映する:

```
diff ~/.claude/settings.json ~/dotfiles/agents/claude/settings.base.json
```

- 配列のキー: base 側にあって既存側に無い項目だけを追記する（既存側にしかない項目は消さない）
- base に無いキー: 既存側をそのまま残す
- base にあるキー: base 側の値を採用する

プロジェクト固有の設定（MCP、プラグイン等）は各プロジェクトの `.claude/settings.local.json` で管理する。

## セットアップ用リンク

既存のリンクや設定を確認し、必要なものだけ作成する。以前の構成で `~/.claude/skills/` 全体を
`dotfiles/claude/skills/` にリンクしていた場合は、参照先を確認してからそのリンクを外し、下記の
スキル単位のリンクへ移行する。共有スキルはスキル単位でリンクする:

```
mkdir -p ~/.claude ~/.claude/skills ~/.codex ~/.codex/skills
ln -s ~/dotfiles/agents/AGENTS.md ~/.claude/CLAUDE.md
ln -s ~/dotfiles/agents/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/dotfiles/agents/claude/commands ~/.claude/commands
ln -s ~/dotfiles/agents/claude/themes ~/.claude/themes

for skill_dir in ~/dotfiles/agents/skills/*; do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_name=${skill_dir:t}
  ln -s "$skill_dir" ~/.claude/skills/"$skill_name"
  ln -s "$skill_dir" ~/.codex/skills/"$skill_name"
done

for skill_dir in ~/dotfiles/agents/claude/skills/*(N); do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_name=${skill_dir:t}
  ln -s "$skill_dir" ~/.claude/skills/"$skill_name"
done

for skill_dir in ~/dotfiles/agents/codex/skills/*; do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_name=${skill_dir:t}
  ln -s "$skill_dir" ~/.codex/skills/"$skill_name"
done
```

## gw との連携

`gw` に Claude Code / Codex のセッション状態を観測させる場合は、既存の hooks 設定を確認してから、`gw` が出力する設定を手動で追加する。`gw` は既存設定を自動変更しない。

```sh
gw guide agent-hook claude
gw guide agent-hook codex
```

Claude Code の設定先は `~/.claude/settings.json`、Codex の設定先は `~/.codex/hooks.json` または `~/.codex/config.toml`。セッション状態は `~/.local/state/gw/sessions.json` に保存され、リポジトリ内には独自メタデータを書き込まない。
