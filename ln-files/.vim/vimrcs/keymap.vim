" V modeでインデント後にN modeにならないように。
vnoremap < <gv
vnoremap > >gv
" Yとyyが同じなので、Yは行末までのコピーに。
nnoremap Y y$

nnoremap ; :
nnoremap : ;

nnoremap <C-t> :NERDTreeToggle<CR>

inoremap <silent> hh <ESC>:w<CR>
inoremap <silent> ｈｈ <ESC>:w<CR>

nnoremap + <C-a>
nnoremap - <C-x>

" コメントアウト
nnoremap <silent> <C-/> :TComment<CR>


" 下段に空行挿入。
" 上段がないし変えるかも。
nnoremap <C-o> mzo<ESC>`z
