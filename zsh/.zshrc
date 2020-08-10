
# append gnubin to PATH
for d in /usr/local/opt/*/libexec/gnubin; do
  export PATH=$d:$PATH
done
