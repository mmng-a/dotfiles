set ignorecase
set smartcase
" 検索が末尾まで終わったら、ファイル先頭から再検索
set wrapscan
set incsearch
set hlsearch

" 再描画時にハイライトを消去
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>
