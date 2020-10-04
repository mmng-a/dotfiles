if executable('xcrun sourcekit-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'xcrun sourcekit-lsp',
        \ 'cmd': {server_info->['xcrun sourcekit-lsp']},
        \ 'whitelist': ['swift'],
        \ })
endif

autocmd FileType swift setlocal omnifunc=lsp#complete
autocmd FileType rs setlocal omnifunc=lsp#complete
" autocmd FileType swift nnoremap <Space>
