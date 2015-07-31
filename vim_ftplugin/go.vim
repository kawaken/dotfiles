set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0

let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['go'] }
let g:syntastic_go_checkers = ['go', 'golint']

autocmd FileType go autocmd BufWritePre <buffer> Fmt
autocmd FileType go :highlight goErr cterm=bold ctermfg=203
autocmd FileType go :match goErr /\<err\>/
