"""""""""""""""""""""""""""""""""""" Coc
nnoremap <Plug>(go-to-definition-call) <Plug>(coc-definition)
nnoremap <Plug>(go-to-declaration-call) <Plug>(coc-declaration)
nnoremap <Plug>(go-to-type-definition-call) <Plug>(coc-type-definition)
nnoremap <Plug>(go-to-implementation-call) <Plug>(coc-implementation)
nnoremap <Plug>(go-to-references-call) <Plug>(coc-references)
nnoremap <Plug>(go-to-diagnostic-prev-call) <Plug>(coc-diagnostic-prev)
nnoremap <Plug>(go-to-diagnostics-next-call) <Plug>(coc-diagnostic-next)

nnoremap <Plug>(go-to-help-call) :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('gh', 'in')
  endif
endfunction

nnoremap <Plug>(auto-code-action-call) <Plug>(coc-codeaction)
nnoremap <Plug>(auto-fix-call) <Plug>(coc-fix-current)
nnoremap <Plug>(auto-rename-call) <Plug>(coc-rename)
nnoremap <Plug>(auto-code-lens-call) <Plug>(coc-codelens-action)
nnoremap <Plug>(auto-format-call) :call CocActionAsync('format')<CR>
nnoremap <Plug>(auto-import-call) :call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>


"call AddListKeyMappings('find-file-call', 'CocList files', 'CocList -I --input=%s files')
"call AddListKeyMappings('grep-file-call', 'CocList grep', 'CocList -I --input=%s grep')
"call AddListKeyMappings('find-buffer-call', 'CocList buffers', 'CocList -I --input=%s buffers')
"call AddListKeyMappings('find-symbol-call', 'CocList symbols', 'CocList -I --input=%s symbols')


nnoremap <Plug>(normal-find-diagnostic-call) :CocList diagnostics<CR>
nnoremap <Plug>(resume-list-call) :CocListResume<CR>

" use enter to confirm the completion
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

if has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

augroup cocGroup
  autocmd!
  autocmd FileType json syntax match Comment +\/\/.\+$+
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  " Hightlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')
  autocmd User CocStatusChange,CocDiagnosticChange doautocmd User LspStatusChange
augroup end

let g:coc_global_extensions = [
    \ 'coc-clangd',
    \ 'coc-cmake',
    \ 'coc-css',
    \ 'coc-docker',
    \ 'coc-go',
    \ 'coc-groovy',
    \ 'coc-json',
    \ 'coc-java',
    \ 'coc-lists',
    \ 'coc-markdownlint',
    \ 'coc-markdown-preview-enhanced',
    \ 'coc-pyright',
    \ 'coc-rust-analyzer',
    \ 'coc-sh',
    \ 'coc-sql',
    \ 'coc-thrift-syntax-support',
    \ 'coc-tsserver',
    \ 'coc-vimlsp',
    \ 'coc-webview',
    \ 'coc-yaml',
    \]

let g:coc_user_config = {
    \ 'suggest': {
        \ 'noselect': v:false,
        \ 'enablePreview': v:true,
    \ },
    \
    \ 'diagnostic': {
        \ 'refreshOnInsertMode': v:true,
        \ 'errorSign': '>>',
        \ 'warningSign': '!!',
        \ 'infoSign': '->',
        \ 'hintSign': '**',
    \ },
    \
    \ 'list.source.files.args': ['--hidden', '--files'],
    \ 'list.source.files.excludePatterns': ['**/.bloop/*'],
    \
    \ 'clangd': {
        \ 'arguments': ['--background-index'],
    \ },
    \
    \ 'markdownlint': {
        \ 'config': {
            \ 'default': v:true,
            \ 'line_length': v:false,
          \ }
    \ },
    \ 'metals': {
        \ 'sbtScript': 'sbt',
        \ 'statusBarEnabled': v:true,
    \ },
    \
    \ 'go': {
        \ 'goplsOptions': {
            \ 'usePlaceholders': v:true,
            \ 'completeUnimported': v:true,
        \ }
    \ },
    \
    \ 'python': {
        \ 'analysis': {
            \ 'diagnosticSeverityOverrides': {
                \ 'reportAssertTypeFailure': "information",
            \ }
        \ },
        \ 'sortImports': {
            \ 'path': 'ruff',
        \ },
        \ 'formatting': {
            \ 'provider': 'black',
        \ },
        \ 'linting': {
            \ 'pylintEnabled': v:true,
            \ 'pylintArgs': ["--rcfile $(workspace python)/google-pylintrc"],
            \ 'ruffEnabled': v:true,
        \ }
    \ },
    \
    \ 'pyright': {
        \ 'organizeimports': {
            \ 'provider': 'ruff',
        \ },
        \ 'testing': {
            \ 'provider': 'pytest',
        \ },
    \ },
    \ 'rust-analyzer': {
        \ 'server': {
        \ }
      \ },
    \
    \ 'workspace.ignoredFolders': [
        \ "$HOME",
        \ "$HOME/.cargo/**",
        \ "$HOME/.restup/**"
      \ ],
    \ 'languageserver': {
        \ 'terraform': {
		    \ 'command': 'terraform-ls',
			\ 'args': ['serve'],
            \ 'filetypes': [
                \ 'terraform',
                \ 'tf'
            \ ],
            \ 'initializationOptions': {},
            \ 'settings': {}
        \ }
    \ },
    \ }

let g:coc_filetype_map = {
    \ 'json5': 'jsonc',
  \ }

function! LspStatus() abort
    return coc#status()
endfunction

