set whichwrap=h,l,[,],<,>
" 挿入モードでバックスペースで削除できるようにする "
set backspace=indent,eol,start

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" 上下移動を論理行でなく表示行の移動に。
noremap j gj
noremap k gk
noremap <Down> gj
noremap <Up> gk
noremap gj j
noremap gk k
" また、Hを^、Lを$にしている。
noremap H ^
noremap L $
noremap J L
noremap K H

" emacsの移動。
inoremap <C-n> <Down>
inoremap <C-p> <Up>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-d> <Del>
inoremap <C-k> <ESC>C
inoremap <C-y> <ESC>pi
inoremap <C-t> <Esc><Left>"zx"zpa

cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>
cnoremap <C-k> <ESC>C
cnoremap <C-y> <ESC>pi
cnoremap <C-t> <Esc><Left>"zx"zpa

" 行を移動
nnoremap <D-Up> "zdd<Up>"zP
nnoremap <D-Down> "zdd"zp
" 複数行を移動
vnoremap <D-Up> "zx<Up>"zP`[V`]
vnoremap <C-Down> "zx"zp`[V`]

nnoremap <D-k> "zdd<Up>"zP
nnoremap <D-j> "zdd"zp
vnoremap <D-k> "zx<Up>"zP`[V`]
vnoremap <D-j> "zx"zp`[V`]
