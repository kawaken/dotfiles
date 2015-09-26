" plugin manager: vim-unbundle
runtime vim-unbundle/plugin/unbundle.vim
runtime macros/matchit.vim

"" general
let mapleader = "\<Space>"
set modeline
set modelines=5
filetype plugin indent on

" cursol
set ww=b,s,<,>,[,]
set backspace=indent,eol,start

" file edit
set enc=utf-8
set fenc=utf-8
set fencs=utf-8,sjis,euc-jp,iso-2022-jp
set fileformats=unix,dos,mac
set hidden

set textwidth=0
set tabstop=2
set expandtab
set shiftwidth=2
set smartindent
function ToggleWrap()
  if (&wrap == 1)
    set nowrap
  else
    set wrap
  endif
endfunction
nmap <silent><C-]> :call ToggleWrap()<CR>

" display
set number
set display=lastline
set pumheight=10
set showmatch
set matchtime=1

" status line
set statusline=%F%m%r%h%w\ POS=%04l,%04v[%p%%]\ L=%L
set laststatus=2
set scrolloff=5

" matchit
let b:match_ignorecase = 1

" search
set hlsearch
set ignorecase
set smartcase
set nowrapscan
nmap <ESC><ESC> :nohlsearch<CR><ESC>

" temporary files
set directory=~/.vim/tmp
set backupdir=~/.vim/tmp
set viminfo+=n~/.vim/tmp/viminfo.txt
augroup swapchoice-readonly
  autocmd!
  autocmd SwapExists * let v:swapchoice = 'o'
augroup END

" complete
set completeopt=menu
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" 全角スペース・行末のスペースの可視化
if has("syntax")
    syntax on
    set t_Co=256
    set background=dark
    let g:solarized_termcolors=256
    let g:solarized_menu=0
    colorscheme solarized

    " PODバグ対策
    syn sync fromstart

    function! ActivateInvisibleIndicator()
        " 下の行の"　"は全角スペース
        syntax match InvisibleJISX0208Space "　" display containedin=ALL
        highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
        syntax match InvisibleTrailedSpace "[ \t]\+$" display containedin=ALL
        highlight InvisibleTrailedSpace term=underline ctermbg=Red guibg=NONE gui=undercurl guisp=darkorange
        "syntax match InvisibleTab "\t" display containedin=ALL
        "highlight InvisibleTab term=underline ctermbg=white gui=undercurl guisp=darkslategray
    endfunction

    augroup invisible
        autocmd! invisible
        autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
    augroup END
endif

"" plugin settings
" quickbuf
let g:qb_hotkey = "<C-b>"

" quickrun
nnoremap <silent> <C-q> :QuickRun<CR>
nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"

" nerdtree
nnoremap <silent> <C-n> :NERDTreeToggle<CR>

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_style_warning_symbol = '⚠'
let g:syntastic_check_on_wq = 0

" vim-togglelist
let g:toggle_list_no_mappings = 1
nmap <script> <silent> <C-l> :call ToggleLocationList()<CR>
nmap <script> <silent> <C-c> :call ToggleQuickfixList()<CR>

" neocomplete
"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
let g:echodoc_enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 2
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif

set cmdheight=2

NeoCompleteEnable
