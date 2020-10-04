let s:JapaneseIM = 'com.apple.inputmethod.Kotoeri.Japanese'
let s:AsciiIM = 'com.apple.inputmethod.Kotoeri.Roman'

function! s:ImActivateFunc(active)
  if a:active
    call system('issw ' . s:JapaneseIM)
  else
    call system('issw ' . s:AsciiIM)
  endif
endfunction

function! s:ImStatusFunc()
  return stridx(system('issw'), s:JapaneseIM) != -1
endfunction

let s:ImStatus = 0

function! s:insertEnter()
  call s:ImActivateFunc(s:ImStatus)
endfunction
function! s:insertLeave()
  let s:ImStatus = s:ImStatusFunc()
  call s:ImActivateFunc(0)
endfunction

augroup ime
  autocmd!
  autocmd InsertEnter * call s:insertEnter()
  autocmd InsertLeave * call s:insertLeave()
augroup END
