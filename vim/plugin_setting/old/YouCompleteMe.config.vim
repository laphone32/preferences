"""""""""""""""""""""""""""""""""""" YouCompleteMe
let g:ycm_filetype_whitelist = {'c' : 1, 'h' : 1, 'cpp' : 1, 'hpp' : 1, 'java' : 1, 'python' : 1, 'sh' : 1, 'pom' : 1, 'scala' : 1}
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_confirm_extra_conf = 1
let g:ycm_always_populate_location_list = 1
" Let clangd fully control code completion
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
let g:ycm_clangd_binary_path = exepath("clangd")
let g:ycm_clangd_args = ['-background-index']

" Semantic trigger
let g:ycm_semantic_triggers =  {
            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
            \ 'cs,lua,javascript': ['re!\w{2}'],
            \ }

let g:ycm_language_server = [
            \ { 'name': 'scala',
            \   'filetypes': [ 'scala' ],
            \   'cmdline': [ 'metals-vim' ],
            \   'project_root_files': [ 'build.sbt' ]
            \ }
            \ ]


" remove annoying preview window appearing on top of vim
let g:ycm_add_preview_to_completeopt = 0
set completeopt-=preview
nnoremap <Plug>(go-to-definition-call) :YcmCompleter GoToDefinition<CR>
nnoremap <Plug>(go-to-declaration-call) :YcmCompleter GoToDeclaration<CR>
nnoremap <Plug>(go-to-implementation-call) :YcmCompleter GoToImplementation<CR>
nnoremap <Plug>(go-to-references-call) :YcmCompleter GoToReferences<CR>
nnoremap <Plug>(go-to-type-definition-call) :YcmCompleter GoToType<CR>
nnoremap <Plug>(go-to-help-call) :YcmCompleter GetDoc<CR>

