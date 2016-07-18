export PROJECT_DIR=$HOME/projects

if [ -e /usr/local/opt/coreutils/libexec/gnubin/ls ]; then 
  # GNU Command Line Tools が入ってるのでLinux(デフォルト)の設定を使用
  :
else
  alias ls='ls -G -F'
  alias ll='ls -l -h'
  alias la='ls -la'
  alias llrt='ls -lrt'
fi

if [ -d /Applications/MacVim.app/Contents/MacOS ]; then
  PATH=/Applications/MacVim.app/Contents/MacOS:$PATH
  alias vim=Vim
fi

if [ -d /Applications/Postgres.app/Contents/Versions/latest/bin ]; then
  PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
fi

if [ -d /usr/local/mysql ]; then
  PATH=$PATH:/usr/local/mysql/bin
fi

if [ -e /opt/local/bin/svn ]; then
  alias svn=/opt/local/bin/svn
fi

# vim:ft=sh
