export PROJECT_DIR=$HOME/projects

alias mysql=/usr/local/mysql/bin/mysql
alias mysqladmin=/usr/local/mysql/bin/mysqladmin

if [ -e /usr/local/opt/coreutils/libexec/gnubin/ls ]; then 
  # GNU Command Line Tools が入ってるのでLinuxの設定を追加
  alias ls='ls -F --color=auto'
  alias la='ls -a --color=auto'
  alias ll='ls -l -h --color=auto'
  alias llrt='ls -lrt --color=auto'
else
  alias ls='ls -G -F'
  alias ll='ls -l -h'
  alias la='ls -la'
  alias llrt='ls -lrt'
fi

# vim:ft=sh
