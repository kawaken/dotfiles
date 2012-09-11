dotfiles
========

my dotfiles.

Install
-------

    ./dot install

Remane "\_" to ".", and copy $HOME.
If a file exists, ask you to overwrite or not.

And, initialize environment.
1. vim plugins
2. projects directory
3. git config

Copy
-------

    ./dot copy

Remane "\_" to ".", and copy $HOME.
If a file exists, ask you to overwrite or not.

Check file timestamp
----------

    ./dot status

Check dotfiles timestamp.
And show ".\*" files are newer or older than "\_\*" files.

Merge files
-----------

    ./dot merge

Check diff and view files in vimdiff.
