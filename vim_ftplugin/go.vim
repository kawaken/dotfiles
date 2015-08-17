set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0

autocmd BufWritePre <buffer> Fmt
:highlight goErr cterm=bold ctermfg=203
:match goErr /\<err\>/

" gocede path
exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
exe "set rtp+=".globpath($GOPATH, "src/github.com/golang/lint/misc/vim")

" syntastic
let g:syntastic_mode_map = { 'mode': 'passive',
            \ 'active_filetypes': ['go'] }
let g:syntastic_go_checkers = ['go', 'golint', 'govet']

" neocomplete
"let g:neocomplete#sources#omni#input_patterns.go = '[^.[:digit:] *\t]\.\w*'
