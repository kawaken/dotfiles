# dotfiles

## 環境構築

たぶんこのリポジトリを見ているということは新規に環境構築をしたいタイミングだと思うので、環境構築についても書いておく。

- VSCode 入れておく
- Homebrew
  - [macOS（または Linux）用パッケージマネージャー — Homebrew](https://brew.sh/index_ja) にあるコマンドを利用
  - `eval "$(/opt/homebrew/bin/brew shellenv)" >> ~/.zshrc_local`

### Homebrew でインストールする

Git と GitHub CLI

```
brew install git gh
gh auth login
```

`gh auth login` しておくと SSH の公開鍵いらないので便利。

WSL の場合はターミナルからはブラウザーが開かないので、
デバイスコードをコピーしておいて直接 Windows 側のブラウザーでログインした後コードを貼り付ける。

良く使うコマンド類(Mac のみ)

```
brew install binutils findutils
brew install gnu-indent gnu-sed gnu-tar gnu-which
brew install diffutils coreutils moreutils
brew install fzf delta jq
```

フォント

```
brew install --cask font-hackgen
```

プログラミング言語

```
brew install go node zig
```

## install

```
cd $HOME

gh repo clone kawaken/dotfiles -- --recurse-submodules

# サブモジュールの初期化を忘れた場合
# cd dotfiles && git submodule update --init --recursive

# gwのインストール（Go 1.26以上）
go install github.com/kawaken/gw/cmd/gw@latest

# gitの設定
mkdir -p .config/git
ln -s dotfiles/git/ignore-global .config/git/ignore
# dotfilesで管理している設定を参照させる
printf '[include]\n  path = ~/dotfiles/git/.gitconfig\n' > .gitconfig

git config user.name "yourname"
git config user.email "yourmail"

# zshの設定
ln -s dotfiles/zsh/_zshenv .zshenv

# fzfの設定
echo 'source <(fzf --zsh)' >> .zshrc_local

# zashikiの設定
mkdir -p .config/zashiki
ln -s ~/{dotfiles,.config}/zashiki/config

# herdrの設定
mkdir -p .config/herdr
ln -s ~/{dotfiles,.config}/herdr/config.toml
ln -s ~/{dotfiles,.config}/herdr/sounds

# dotfilesリポジトリ用のメールアドレスを設定（git/.gitconfig-me を参照）
cd dotfiles
git config user.email "$(git config -f git/.gitconfig-me user.email)"
cd ~

# プロジェクトディレクトリ（Go風パス構成）
mkdir -p ~/projects/src/github.com/kawaken
mkdir -p ~/projects/src/github.com/<org>
```

### Claude Code / Codex の設定

ユーザー共通指示、共有スキル、Claude Code / Codex 固有設定のセットアップは
[`agents/README.md`](agents/README.md) を参照。

### gw

`gw` は Git worktree の作成・状態確認・実行中プロセスのlock・cleanup、GitHub の pull request、Claude Code / Codex のセッション状態を扱う CLI。エージェントの起動は行わない。

```sh
gw list
gw list --time
gw inspect <worktree>
gw new [<name>]
gw lock <worktree> --pid <pid>
gw unlock <worktree>
gw clean --dry-run
gw clean
```

GitHub の pull request 情報を取得するため、`gh auth login` を済ませておく。エージェント連携を有効にする場合は、既存設定を確認したうえで次のコマンドが出力する hook を手動で追加する。

```sh
gw guide agent-hook claude
gw guide agent-hook codex
```

外部ツールからエージェントを起動する場合は、`GW_MANAGED=1` を付けたうえで、起動中に `gw lock <worktree> --pid <pid>`、終了時に `gw unlock <worktree>` を実行する。生きたlockがあるworktreeはcleanup対象にならない。

JSON連携では `gw list --json` / `gw inspect --json` / `gw refresh --json` / `gw clean --json` の `schema_version` が `3`。`worktrees[].github.status` は `found`（PRあり）、`not_found`（PRなし）、`unknown`（確認不能なworktree）、`unavailable`（GitHub連携の利用不可・取得失敗）を表し、取得元は `sources.github`、取得エラーは `errors` に入る。
`worktrees[].lock`、`git.uncommitted`、`git.unpushed`、`github.pr.head_oid` が追加され、agentの `lifecycle` には `managed` がある。`gw new --json` は `name`、`path`、`branch`、`base`、`created` を返す。`clean --json` は `planned` / `removed` / `skipped` を含み、`removed` もパスの配列ではなく削除内容を含むオブジェクトの配列になった。`gw list --time --json` では `git.updated_at` も出力される。
旧キャッシュの `available` は、PRの有無に応じて `found` または `not_found` に読み替えられる。
