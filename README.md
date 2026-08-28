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

# Claude Code / Codex のユーザー共通指示
mkdir -p ~/.claude ~/.codex
ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/dotfiles/claude/CLAUDE.md ~/.codex/AGENTS.md
ln -s ~/dotfiles/claude/commands ~/.claude/commands
ln -s ~/dotfiles/claude/skills ~/.claude/skills
ln -s ~/dotfiles/claude/themes ~/.claude/themes

# dotfilesリポジトリ用のメールアドレスを設定（git/.gitconfig-me を参照）
cd dotfiles
git config user.email "$(git config -f git/.gitconfig-me user.email)"
cd ~

# プロジェクトディレクトリ（Go風パス構成）
mkdir -p ~/projects/src/github.com/kawaken
mkdir -p ~/projects/src/github.com/<org>
```

### Claude Code / Codex の設定

`claude/CLAUDE.md` は Claude Code と Codex のユーザー共通指示の正本。
Claude Code は `~/.claude/CLAUDE.md`、Codex は `~/.codex/AGENTS.md` から同じファイルを読む。
Claude Code 固有の設定は、共通指示に混ぜず `~/.claude/` 側で管理する。

`claude/settings.base.json` を `~/.claude/settings.json` に反映する（permissions、statusLine などを含む）。

```
# 新規: そのままコピー
cp ~/dotfiles/claude/settings.base.json ~/.claude/settings.json

# 既存: 差分を確認して手動で反映する
diff ~/.claude/settings.json ~/dotfiles/claude/settings.base.json
```

`jq -s '.[0] * .[1]'` のような機械的マージは使わない。`*` 演算子は配列
（`permissions.allow`/`deny` など）を丸ごと後勝ちで上書きし、既存側にだけ追加していた
許可項目が消える。反映のルールは `claude/README.md` を参照。

### gw

`gw` は Git worktree、GitHub の pull request、Claude Code / Codex のセッション状態を確認し、不要になった worktree の cleanup 候補を判定する CLI。worktree の作成やエージェントの起動は行わない。

```sh
gw list
gw inspect <worktree>
gw clean --dry-run
gw clean
```

GitHub の pull request 情報を取得するため、`gh auth login` を済ませておく。エージェント連携を有効にする場合は、既存設定を確認したうえで次のコマンドが出力する hook を手動で追加する。

```sh
gw guide agent-hook claude
gw guide agent-hook codex
```
