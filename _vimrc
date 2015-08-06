" plugin manager: vim-unbundle
runtime vim-unbundle/plugin/unbundle.vim
runtime macros/matchit.vim

"" general
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
set completeopt=menu,preview
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" 全角スペース・行末のスペースの可視化
if has("syntax")
    syntax on
    set t_Co=256
    set background=dark
    let g:solarized_termcolors=256
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
