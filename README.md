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

# ghosttyの設定
mkdir -p .config/ghostty
ln -s ~/{dotfiles,.config}/ghostty/config

# Claudeの設定
mkdir -p .claude
ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/dotfiles/claude/commands ~/.claude/commands
ln -s ~/dotfiles/claude/skills ~/.claude/skills

# プロジェクトディレクトリ（Go風パス構成）
mkdir -p ~/projects/src/github.com/kawaken
mkdir -p ~/projects/src/github.com/<org>
```

### Claude Code の設定

Hooks（Bashバリデーション等）とステータスラインの設定は `claude/` 配下のスクリプトを参照し `~/.claude/settings.json` に設定する。

依存: `jq`
