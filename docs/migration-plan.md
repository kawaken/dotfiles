# dotfiles → chezmoi 移行計画

## Context

現在のdotfilesはシンボリックリンク（手動）で管理しているが、chezmoiに移行してファイルコピーベースの管理に切り替える。chezmoiにより、`chezmoi init --apply` の1コマンドで環境構築が完了する状態を目指す。Homebrew等の自動インストールは後回しにし、まずはファイル管理の移行に集中する。

## 方針決定事項

- **ZDOTDIR**: `~/.config/zsh`
- **git/bin/**: `~/.local/bin`
- **Homebrew自動化**: 後回し
- **リポジトリ構造**: `.chezmoiroot` で `home/` 配下をソースディレクトリに指定

---

## リポジトリ構造（移行後）

```
dotfiles/                          # リポジトリルート
├── .chezmoiroot                   # 内容: "home"
├── .github/                       # そのまま（chezmoi対象外）
├── .claude/settings.json          # そのまま（chezmoi対象外）
├── .editorconfig                  # そのまま（chezmoi対象外）
├── .gitignore                     # 更新
├── CLAUDE.md                      # 更新（パス変更反映）
├── README.md                      # 更新（chezmoi手順に書き換え）
└── home/                          # chezmoiソースディレクトリ
    ├── .chezmoi.toml.tmpl         # chezmoi設定テンプレート（最小限）
    ├── .chezmoiexternal.toml      # 外部依存（zsh-syntax-highlighting）
    ├── dot_zshenv                 # ~/.zshenv（ZDOTDIR変更）
    ├── dot_gitconfig              # ~/.gitconfig（パス変更）
    ├── dot_gitconfig-me           # ~/.gitconfig-me
    ├── dot_claude/
    │   ├── CLAUDE.md
    │   ├── executable_statusline.sh
    │   ├── commands/
    │   │   └── cmp.md
    │   └── skills/
    │       └── cp/
    │           └── SKILL.md
    ├── dot_config/
    │   ├── git/
    │   │   ├── delta              # delta表示設定
    │   │   └── ignore             # グローバルgitignore
    │   ├── ghostty/
    │   │   └── config
    │   └── zsh/                   # ZDOTDIR = ~/.config/zsh
    │       ├── dot_zshrc          # メインzsh設定
    │       ├── dot_zshrc_Darwin   # macOS固有
    │       ├── plugins/           # 各プラグイン（11ファイル）
    │       │   ├── 00_path_utils
    │       │   ├── aliases
    │       │   ├── completion
    │       │   ├── dotfiles_bin   # パス変更: ~/.local/bin
    │       │   ├── fzf
    │       │   ├── git            # パス変更: $ZDOTDIR/rc
    │       │   ├── homebrew_path
    │       │   ├── jira
    │       │   ├── keybindings
    │       │   ├── workon
    │       │   └── z-syntax-highlighting  # パス変更なし（$ZDOTDIR参照済み）
    │       ├── rc/                # zsh関数
    │       │   ├── git_branch_status
    │       │   └── git_gw
    │       └── templates/         # gwテンプレート
    │           └── dot_gw.sh.template
    └── dot_local/
        └── bin/                   # カスタムコマンド
            ├── executable_git-branch-jira
            ├── executable_git-cleanup-branches
            ├── executable_git-delete-branch
            ├── executable_git-fixup-wip
            ├── executable_git-log-all
            ├── executable_git-log-recent
            ├── executable_git-log-unpushed
            └── executable_jira-auto-sync
```

---

## ファイルマッピング表

| 旧パス | chezmoiソース（home/配下） | デプロイ先 |
|---|---|---|
| `zsh/_zshenv` | `dot_zshenv` | `~/.zshenv` |
| `zsh/.zshrc` | `dot_config/zsh/dot_zshrc` | `~/.config/zsh/.zshrc` |
| `zsh/.zshrc_Darwin` | `dot_config/zsh/dot_zshrc_Darwin` | `~/.config/zsh/.zshrc_Darwin` |
| `zsh/plugins/*`（11ファイル） | `dot_config/zsh/plugins/*` | `~/.config/zsh/plugins/*` |
| (submodule) zsh-syntax-highlighting | `.chezmoiexternal.toml`で定義 | `~/.config/zsh/plugins/zsh-syntax-highlighting/` |
| `git/.gitconfig` | `dot_gitconfig` | `~/.gitconfig` |
| `git/.gitconfig-me` | `dot_gitconfig-me` | `~/.gitconfig-me` |
| `git/delta` | `dot_config/git/delta` | `~/.config/git/delta` |
| `git/ignore-global` | `dot_config/git/ignore` | `~/.config/git/ignore` |
| `git/bin/*`（7ファイル） | `dot_local/bin/executable_git-*` | `~/.local/bin/git-*` |
| `git/rc/git_branch_status` | `dot_config/zsh/rc/git_branch_status` | `~/.config/zsh/rc/git_branch_status` |
| `git/rc/git_gw` | `dot_config/zsh/rc/git_gw` | `~/.config/zsh/rc/git_gw` |
| `git/templates/.gw.sh.template` | `dot_config/zsh/templates/dot_gw.sh.template` | `~/.config/zsh/templates/.gw.sh.template` |
| `ghostty/config` | `dot_config/ghostty/config` | `~/.config/ghostty/config` |
| `claude/CLAUDE.md` | `dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `claude/statusline.sh` | `dot_claude/executable_statusline.sh` | `~/.claude/statusline.sh` |
| `claude/commands/cmp.md` | `dot_claude/commands/cmp.md` | `~/.claude/commands/cmp.md` |
| `claude/skills/cp/SKILL.md` | `dot_claude/skills/cp/SKILL.md` | `~/.claude/skills/cp/SKILL.md` |
| `scripts/jira-auto-sync` | `dot_local/bin/executable_jira-auto-sync` | `~/.local/bin/jira-auto-sync` |

---

## 内容修正が必要なファイル

### 1. `dot_zshenv`（旧 `zsh/_zshenv`）

```diff
- export ZDOTDIR=$HOME/dotfiles/zsh
+ export ZDOTDIR=$HOME/.config/zsh
```

### 2. `dot_gitconfig`（旧 `git/.gitconfig`）

```diff
  [include]
    path = .gitconfig.local
-   path = ~/dotfiles/git/delta
+   path = ~/.config/git/delta
  [core]
    pager = delta
-   excludesFile = ~/dotfiles/git/ignore-global
+   excludesFile = ~/.config/git/ignore
  [includeIf "gitdir:~/projects/src/github.com/kawaken/"]
-   path = ~/dotfiles/git/.gitconfig-me
+   path = ~/.gitconfig-me
```

### 3. `plugins/dotfiles_bin`

```diff
- if [ -d "$HOME/dotfiles/git/bin" ]; then
-   export PATH="$HOME/dotfiles/git/bin:$PATH"
+ if [ -d "$HOME/.local/bin" ]; then
+   export PATH="$HOME/.local/bin:$PATH"
  fi
```

### 4. `plugins/git`（パス参照方式の変更）

```diff
- local base_dir=${0:A:h}
- for file in $(find "${base_dir}/../../git/rc" -type f); do
-   source "$file"
- done
+ for file in $ZDOTDIR/rc/*(.); do
+   source "$file"
+ done
```

### 5. `scripts/jira-auto-sync`（→ `~/.local/bin/jira-auto-sync`）

```diff
- [[ -z ${functions[jira_fetch]} ]] && source ~/dotfiles/zsh/plugins/jira
+ [[ -z ${functions[jira_fetch]} ]] && source ~/.config/zsh/plugins/jira
```

### 6. `git_gw` のテンプレートパス

現在の参照: `${${(%):-%x}:A:h}/../templates/.gw.sh.template`
- 現在: `git/rc/` → `../` → `git/` → `templates/`
- 移行後: `~/.config/zsh/rc/` → `../` → `~/.config/zsh/` → `templates/`
- **相対パスが維持されるため変更不要**

---

## 新規作成ファイル

### `.chezmoiroot`
```
home
```

### `home/.chezmoiexternal.toml`
```toml
[".config/zsh/plugins/zsh-syntax-highlighting"]
    type = "git-repo"
    url = "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    refreshPeriod = "168h"
```

### `home/.chezmoi.toml.tmpl`（最小限）
```toml
```
（空でOK。将来マシン固有設定を追加する際の器）

---

## 実装手順

### Step 1: ディレクトリ構造の準備
1. `home/` ディレクトリを作成
2. `.chezmoiroot` を作成
3. `home/.chezmoiexternal.toml` を作成
4. `home/.chezmoi.toml.tmpl` を作成（空）

### Step 2: ファイルの配置（コピー＆リネーム）
5. zsh関連ファイルを `home/dot_config/zsh/` 配下に配置
6. git設定ファイルを `home/dot_config/git/` と `home/` に配置
7. git/bin/* を `home/dot_local/bin/executable_git-*` に配置
8. git/rc/* を `home/dot_config/zsh/rc/` に配置
9. git/templates/ を `home/dot_config/zsh/templates/` に配置
10. ghostty/config を `home/dot_config/ghostty/` に配置
11. claude/* を `home/dot_claude/` に配置
12. scripts/jira-auto-sync を `home/dot_local/bin/executable_jira-auto-sync` に配置

### Step 3: ファイル内容の修正
13. `dot_zshenv`: ZDOTDIRパス変更
14. `dot_gitconfig`: include/excludesFileパス変更
15. `plugins/dotfiles_bin`: PATH変更
16. `plugins/git`: rc参照パス変更
17. `jira-auto-sync`: sourceパス変更

### Step 4: クリーンアップ
18. 旧ディレクトリ（`zsh/`, `git/`, `ghostty/`, `claude/`, `scripts/`）を削除
19. `.gitmodules` を削除
20. `.gitignore` を更新
21. `CLAUDE.md` を更新（パス変更反映）
22. `README.md` を更新（chezmoi手順に書き換え）

### Step 5: CLAUDE.md の更新
- ディレクトリ構造説明を新構造に更新
- シンボリックリンクの説明をchezmoiの説明に変更
- パス参照を新しいパスに更新

---

## 検証方法

1. `chezmoi init --source=.` でリポジトリをソースとして初期化
2. `chezmoi diff` で適用される変更を確認
3. `chezmoi apply -v --dry-run` でドライラン
4. `chezmoi apply -v` で実際に適用
5. 既存シンボリックリンクを削除してから適用（`~/.zshenv`, `~/.gitconfig` 等）
6. 新しいzshセッションを開いてプラグインが正常にロードされるか確認
7. `git-*` コマンドが `~/.local/bin` から実行できるか確認
8. `gw` コマンドのテンプレート機能が動作するか確認
