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

## Codex 専用設定

Codex remote-control を `workspace-write` で使う場合、worktree のソースファイルは書き込めても、Git の
メタデータ（`fetch` や `commit` が更新する `.git` 以下）が別の場所にあるため、`Permission denied` になる
ことがある。これは Git の所有権や worktree の配置ではなく、sandbox の書き込み境界によるもの。

この症状が出た場合は、マシン側の `~/.codex/config.toml` に `[sandbox_workspace_write].writable_roots` を
設定する必要がある。設定はマシン固有のパスを含むため、このリポジトリでは管理しない。設定の仕様と
注意点は、公式の [Configuration Reference](https://learn.chatgpt.com/docs/config-file/config-reference)、
[Advanced Configuration](https://learn.chatgpt.com/docs/config-file/config-advanced)、
[Git worktrees](https://learn.chatgpt.com/docs/environments/git-worktrees) を参照して設定する。

`Worktree root` はソース用 worktree の配置場所を変える設定であり、Git メタデータの書き込み権限とは別。
`approval_policy = "never"` も承認確認を省くだけで sandbox 境界は変えない。`danger-full-access` より、必要な
リポジトリの `.git` だけを `writable_roots` に追加する方法を優先する。設定を変更した後は、remote-control
daemon の再起動とアプリからの再接続が必要。

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

既存のリンクや設定を確認し、必要なものだけ作成する。以前の構成で `~/.claude/skills/` または
`~/.codex/skills/` 全体を旧ディレクトリへリンクしていた場合は、参照先を `readlink` で確認してから
そのディレクトリリンクだけを外し、下記のスキル単位のリンクへ移行する。実ファイルや実ディレクトリは
削除しない。共有スキルはスキル単位でリンクする:

```
# 旧構成のディレクトリ全体リンクを使っている場合だけ、参照先を確認してから外す
if [[ -L ~/.claude/skills ]]; then
  readlink ~/.claude/skills
  unlink ~/.claude/skills
fi
if [[ -L ~/.codex/skills ]]; then
  readlink ~/.codex/skills
  unlink ~/.codex/skills
fi

link_if_safe() {
  local source=$1 target=$2
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "skip: $target exists and is not a symbolic link"
    return
  fi
  ln -sfn "$source" "$target"
}

mkdir -p ~/.claude ~/.claude/skills ~/.codex ~/.codex/skills
link_if_safe ~/dotfiles/agents/AGENTS.md ~/.claude/CLAUDE.md
link_if_safe ~/dotfiles/agents/AGENTS.md ~/.codex/AGENTS.md
link_if_safe ~/dotfiles/agents/claude/commands ~/.claude/commands
link_if_safe ~/dotfiles/agents/claude/themes ~/.claude/themes

for skill_dir in ~/dotfiles/agents/skills/*; do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_name=${skill_dir:t}
  link_if_safe "$skill_dir" ~/.claude/skills/"$skill_name"
  link_if_safe "$skill_dir" ~/.codex/skills/"$skill_name"
done

for skill_dir in ~/dotfiles/agents/claude/skills/*(N); do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_name=${skill_dir:t}
  link_if_safe "$skill_dir" ~/.claude/skills/"$skill_name"
done

for skill_dir in ~/dotfiles/agents/codex/skills/*(N); do
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_name=${skill_dir:t}
  link_if_safe "$skill_dir" ~/.codex/skills/"$skill_name"
done
```

## gw との連携

`gw` に Claude Code / Codex のセッション状態を観測させる場合は、既存の hooks 設定を確認してから、`gw` が出力する設定を手動で追加する。`gw` は既存設定を自動変更しない。

```sh
gw guide agent-hook claude
gw guide agent-hook codex
```

Claude Code の設定先は `~/.claude/settings.json`、Codex の設定先は `~/.codex/hooks.json` または `~/.codex/config.toml`。セッション状態は `~/.local/state/gw/sessions.json` に保存され、リポジトリ内には独自メタデータを書き込まない。
