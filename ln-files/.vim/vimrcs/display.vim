set number
set title
set autoindent
set ruler
set list
set listchars=tab:├─,trail:␣,eol:⏎,extends:»,precedes:«,nbsp:%
set cursorline
set wrap
set display=lastline
set pumheight=10
set showmatch
syntax on
source $VIMRUNTIME/macros/matchit.vim " Vimの「%」を拡張する

" カーソルの形
let &t_SI .= "\e[6 q"
let &t_EI .= "\e[2 q"
let &t_SR .= "\e[4 q"

" au[tocmd] hi[ghlight]
au ColorScheme * hi SpecialKey ctermfg=241 guifg=#606060
au ColorScheme * hi EndOfBuffer ctermfg=241 guifg=#606060
au ColorScheme * hi NonText ctermfg=241 guifg=#606060
colorscheme iceberg

" status line
set laststatus=2
set noshowmode
let g:lightline = {
	\ 'colorscheme': 'icebergDark'
	\ }

