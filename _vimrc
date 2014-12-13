:runtime bundle/vim-unbundle/unbundle.vim

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
set scrolloff=5

set number
set autoindent
set ruler
set shiftwidth=2
set tabstop=2
set list
set listchars=tab:>\ ,trail:-,nbsp:%,extends:>,precedes:<
set nobackup

set ww=b,s,h,l,<,>,[,]

"inoremap {} {}<Left>
"inoremap [] []<Left>
"inoremap () ()<Left>
"inoremap "" ""<Left>
"inoremap '' ''<Left>
"inoremap <> <><Left>

" search
set hlsearch
set ignorecase
set smartcase
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
set tw=0

"タブ幅をリセット
au FileType * setl expandtab tabstop=2 shiftwidth=2 softtabstop=2

" vim settings
autocmd FileType vim setl expandtab tabstop=2 shiftwidth=2 softtabstop=2

" python settings
autocmd FileType python setl autoindent
autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType python setl expandtab tabstop=4 shiftwidth=4 softtabstop=4

" ruby settings
autocmd FileType ruby setl autoindent
autocmd BufNewFile,BufRead Gemfile setl filetype=ruby

" sh settings
autocmd FileType sh setl autoindent
autocmd FileType sh setl smartindent

autocmd FileType go setl autoindent
autocmd FileType go setl smartindent
autocmd FileType go setl tabstop=4 shiftwidth=4 softtabstop=0
autocmd FileType go setl noexpandtab
auto BufWritePre *.go Fmt

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

set completeopt=menuone
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#max_list = 20
let g:neocomplete#auto_completion_start_length = 3
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
inoremap <expr><Space> pumvisible() ? neocomplete#close_popup()."\<Space>" : "\<Space>"

" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  " return neocomplete#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction

if !exists('g:neocomplete#omni_patterns')
  let g:neocomplete#omni_patterns = {}
endif
let g:neocomplete#omni_patterns.go = '\h\w*\.\?'

let g:qb_hotkey = "<C-T>"

" switch
let b:switch_custom_definitions = [
      \   ["describe", "context", "specific", "example"],
      \   ['before', 'after'],
      \   ['be_true', 'be_false'],
      \   ['get', 'post', 'put', 'delete'],
      \   ['==', 'eql', 'equal'],
      \   { '\.should_not': '\.should' },
      \   ['\.to_not', '\.to'],
      \   { '\([^. ]\+\)\.should\(_not\|\)': 'expect(\1)\.to\2' },
      \   { 'expect(\([^. ]\+\))\.to\(_not\|\)': '\1.should\2' },
      \ ]

imap <silent><C-F> <Plug>(neosnippet_expand_or_jump)

set splitright

" load private settings
if filereadable("$HOME/.vim/private")
    source "$HOME/.vim/private"
endif
