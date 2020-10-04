" バッファが編集中でもその他のファイルを開けるように "
set hidden
set showcmd
" vim の矩形選択で文字が無くても右へ進める "
set virtualedit=block
set ambiwidth=single
" EXモードでの補完
set wildmenu
set history=5000

setlocal foldmethod=marker
set clipboard=unnamed

set nrformats-=octal
set ttimeoutlen=50
autocmd BufWritePre * :%s/\s\+$//ge

set scrolloff=5

set smarttab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smartindent
set autoindent

autocmd BufNewFile,BufRead *.hs setlocal expandtab

" ペースト時にインデントしないように。
if &term =~ "xterm"
    let &t_SI .= "\e[?2004h"
    let &t_EI .= "\e[?2004l"
    let &pastetoggle = "\e[201~"

    function XTermPasteBegin(ret)
        set paste
        return a:ret
    endfunction

    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif
