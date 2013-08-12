filetype plugin indent off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'alpaca-tc/alpaca_tags'
NeoBundle 'alpaca-tc/neorspec.vim'
NeoBundle 'alpaca-tc/vim-endwise.git'
NeoBundle 'altercation/vim-colors-solarized.git'
NeoBundle 'AndrewRadev/switch.vim'
NeoBundle 'ecomba/vim-ruby-refactoring'
NeoBundle 'jnwhiteh/vim-golang'
NeoBundle 'mattn/gist-vim'
NeoBundle 'mattn/webapi-vim'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'QuickBuf'
NeoBundle 'Shougo/neobundle.vim.git'
NeoBundle 'Shougo/neocomplete.git'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/unite.vim.git'
NeoBundle 'Shougo/vimproc.git'
NeoBundle 'taka84u9/vim-ref-ri'
NeoBundle 'tpope/vim-rails'
NeoBundle 'tsaleh/vim-matchit'
NeoBundle 'vim-scripts/surround.vim.git'

if isdirectory("$GOROOT/misc/vim")
  set rtp+=$GOROOT/misc/vim
endif
exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")

filetype plugin indent on

syntax enable
set t_Co=256
set background=dark
let g:solarized_termcolors=256
colorscheme solarized

set modeline
set modelines=5
set nocompatible
set backspace=indent,eol,start
set fileformats=unix,dos,mac

set enc=utf-8
set fenc=utf-8
set fencs=utf-8,sjis,euc-jp,iso-2022-jp

set statusline=%F%m%r%h%w\ POS=%04l,%04v[%p%%]\ L=%L
set laststatus=2

set number
set autoindent
set ruler
set shiftwidth=4
set tabstop=4
set list
set listchars=tab:>\ ,trail:-,nbsp:%,extends:>,precedes:<
set nobackup

set ww=b,s,h,l,<,>,[,]

" Key mapping
inoremap <C-^> <Home>
inoremap <C-\> <End>
inoremap <C-d> <Del>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <C-h> <Left>

inoremap <C-Space> <C-x><C-o>

map <C-CR> g<C-]>
map <C-BS> <C-t>

"inoremap {} {}<Left>
"inoremap [] []<Left>
"inoremap () ()<Left>
"inoremap "" ""<Left>
"inoremap '' ''<Left>
"inoremap <> <><Left>


" search
set ignorecase
nmap <ESC><ESC> :nohlsearch<CR><ESC>

set cursorline
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END

:hi clear CursorLine
"highlight CursorLine cterm=underline gui=underline
highlight CursorLine ctermbg=black guibg=black

set noswapfile

"タブ幅をリセット
au FileType * setl expandtab tabstop=4 shiftwidth=4 softtabstop=4

" vim settings
autocmd FileType vim setl expandtab tabstop=2 shiftwidth=2 softtabstop=2

" python settings
autocmd FileType python setl autoindent
autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType python setl expandtab tabstop=4 shiftwidth=4 softtabstop=4

" ruby settings
autocmd FileType ruby setl autoindent
autocmd FileType ruby setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.rhtml setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.rb setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.erb setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.yml setl tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.rake setl tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead Gemfile setl tabstop=2 shiftwidth=2 softtabstop=2 filetype=ruby


" sh settings
autocmd FileType sh setl autoindent
autocmd FileType sh setl smartindent
autocmd FileType sh setl expandtab tabstop=2 shiftwidth=2 softtabstop=2

autocmd FileType go setl autoindent
autocmd FileType go setl smartindent
autocmd FileType go setl tabstop=4 shiftwidth=4 softtabstop=0
autocmd FileType go setl noexpandtab
auto BufWritePre *.go Fmt

set completeopt=menuone
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#max_list = 20
let g:neocomplete#auto_completion_start_length = 2
let g:neocomplete#manual_completion_start_length = 0
let g:neocomplete#min_keyword_length = 3
let g:neocomplete#min_syntax_length = 3
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#cursor_hold_i_time = 500
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
inoremap <expr><C-g> neocomplete#undo_completion()
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><C-h> pumvisible() ? neocomplete#cancel_popup()."\<C-h>" : "\<C-h>"
inoremap <expr><BS> pumvisible() ? neocomplete#cancel_popup()."\<C-h>" : "\<C-h>"
if !exists('g:neocomplete#omni_patterns')
  let g:neocomplete#omni_patterns = {}
endif
let g:neocomplete#omni_patterns.go = '\h\w*\.\?'

let g:qb_hotkey = "<C-TAB>" 

let g:gist_show_privates = 1
let g:gist_post_private = 1
let g:gist_detect_filetype = 1

" load private settings
if filereadable("$HOME/.vim/private")
    source "$HOME/.vim/private"
endif
