filetype plugin indent off

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
  call neobundle#rc(expand('~/.vim/bundle/'))
endif

NeoBundle 'Shougo/neocomplcache.git'
NeoBundle 'Shougo/neobundle.vim.git'
NeoBundle 'Shougo/unite.vim.git'
NeoBundle 'Shougo/vimshell.git'
NeoBundle 'Shougo/vimproc.git'
NeoBundle 'QuickBuf'
NeoBundle 'altercation/vim-colors-solarized.git'

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
highlight CursorLine cterm=underline gui=underline
highlight CursorLine ctermbg=black guibg=black

set noswapfile

"タブ幅をリセット
au BufNewFile,BufRead * setl expandtab tabstop=4 shiftwidth=4 softtabstop=4

" python settings
autocmd FileType python setl autoindent
autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType python setl expandtab tabstop=4 shiftwidth=4 softtabstop=4

" ruby settings
autocmd FileType ruby setl autoindent
autocmd FileType ruby setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.rhtml setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd BufNewFile,BufRead *.yml setl tabstop=2 shiftwidth=2 softtabstop=2

" sh settings
autocmd FileType sh setl autoindent
autocmd FileType sh setl smartindent
autocmd FileType sh setl expandtab tabstop=2 shiftwidth=2 softtabstop=2

set completeopt=menuone
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_max_list = 20
let g:neocomplcache_auto_completion_start_length = 2
let g:neocomplcache_manual_completion_start_length = 0
let g:neocomplcache_min_keyword_length = 3
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_cursor_hold_i_time = 500
"let g:neocomplcache_omni_patterns = {}
"let g:neocomplcache_enable_cursor_hold_i = 1
inoremap <expr><C-x><C-f> neocomplcache#filename_complete()
inoremap <expr><C-Space> neocomplcache#manual_omni_complete()
inoremap <expr><C-n> pumvisible() ? "\<C-n>" : neocomplcache#manual_keyword_complete()
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()
inoremap <expr><C-g> neocomplcache#undo_completion()
imap <C-s> <Plug>(neocomplcache_snippets_expand) 
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><C-h> pumvisible() ? neocomplcache#cancel_popup()."\<C-h>" : "\<C-h>"
inoremap <expr><BS> pumvisible() ? neocomplcache#cancel_popup()."\<C-h>" : "\<C-h>"
inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"

let g:qb_hotkey = "<C-TAB>" 
