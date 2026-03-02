# dotfiles

## 環境構築

たぶんこのリポジトリを見ているということは新規に環境構築をしたいタイミングだと思うので、環境構築についても書いておく。

- VSCode 入れておく
- Homebrew
  - [macOS（または Linux）用パッケージマネージャー — Homebrew](https://brew.sh/index_ja) にあるコマンドを利用
  - `eval "$(/opt/homebrew/bin/brew shellenv)" >> ~/.zshrc_local`

### Homebrew でインストールする

良く使うコマンド類(Mac のみ)

```
brew install binutils findutils
brew install findutils
brew install gnu-indent gnu-sed gnu-tar gnu-which
brew install diffutils coreutils moreutils
```

Git と GitHub CLI

```
brew install git gh
gh auth login
```

`gh auth login` しておくと SSH の公開鍵いらないので便利。

WSL の場合はターミナルからはブラウザーが開かないので、
デバイスコードをコピーしておいて直接 Windows 側のブラウザーでログインした後コードを貼り付ける。

プログラミング言語

```
brew install go node zig
```

## install

```
# gh コマンドの設定済み内容を待避、後からincludeされる
mv .gitconfig .gitconfig.local

cd $HOME
gh repo clone kawaken/dotfiles -- --recurse-submodules

# gitの設定
mkdir -p .config/git
ln -s dotfiles/git/ignore-global .config/git/ignore
ln -s dotfiles/git/.gitconfig .gitconfig

git config --file ~/.gitconfig.local user.name "yourname"
git config --file ~/.gitconfig.local user.email "yourmail"

# zshの設定
ln -s dotfiles/zsh/_zshenv .zshenv

# fzfの設定
brew install fzf
echo 'source <(fzf --zsh)' >> .zshrc_local

## delta
brew install delta

# ghosttyの設定
mkdir -p .config/ghostty
ln -s ~/{dotfiles,.config}/ghostty/config

# Claudeの設定
mkdir -p .claude
ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/dotfiles/claude/commands ~/.claude/commands
ln -s ~/dotfiles/claude/skills ~/.claude/skills
```

### Claude Code ステータスライン

gitリポジトリ情報、モデル名、コンテキスト使用率、TODO進捗をステータスラインに表示するスクリプト。

表示例: `dotfiles [main] :: [Sonnet 4.6] 23%`

依存: `jq`

`~/.claude/settings.json` に以下を追加:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/dotfiles/claude/statusline.sh"
  }
}
```
