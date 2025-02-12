# dotfiles

## 環境構築

たぶんこのリポジトリを見ているということは新規に環境構築をしたいタイミングだと思うので、環境構築についても書いておく。

- VSCode 入れておく
- Homebrew
  - [macOS（または Linux）用パッケージマネージャー — Homebrew](https://brew.sh/index_ja) にあるコマンドを利用
  - `eval "$(/opt/homebrew/bin/brew shellenv)" >> ~/.zshrc_local`

### Homebrew でインストールする

良く使うコマンド類(Macのみ)

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

WSLの場合はターミナルからはブラウザーが開かないので、
デバイスコードをコピーしておいて直接Windows側のブラウザーでログインした後コードを貼り付ける。

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
```

# Apps

普段使いしているアプリケーション

- [Alfred \- Productivity App for macOS](https://www.alfredapp.com/)
- [Download – KeePassXC](https://keepassxc.org/download/#macos) : 仕事用
- [日本語入力システム｢ATOK｣ \| ATOK Passport \|【公式】ATOK\.com](https://atok.com/)
- [Magnet – Window manager for Mac](https://magnet.crowdcafe.com/index.html)
