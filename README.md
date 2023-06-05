# dotfiles

## 環境構築

たぶんこのリポジトリを見ているということは新規に環境構築をしたいタイミングだと思うので、環境構築についても書いておく。

- VSCode 入れておく
- Homebrew
  - [macOS（または Linux）用パッケージマネージャー — Homebrew](https://brew.sh/index_ja) にあるコマンドを利用
  - `eval "$(/opt/homebrew/bin/brew shellenv)" >> ~/.zshrc_local`

### Homebrew でインストールする

良く使うコマンド類

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

プログラミング言語

```
brew install go node zig
```

## install

```
cd $HOME
gh repo clone kawaken/dotfiles

# gitの設定
mkdir -p .config/git
ln -s dotfiles/git/ignore-global .config/git/ignore
ln -s dotfiles/git/.gitconfig .gitconfig

git config --file ~/.gitconfig.local user.name "yourname"
git config --file ~/.gitconfig.local user.email "yourmail"

# zshの設定
ln -s dotfiles/zsh/_zshenv .zshenv
```

### fzf

```
brew install fzf
```

`Do you want to update your shell configuration files? ([y]/n)` にたいしては `N` とする。

```
$(brew --prefix)/opt/fzf/install
```
