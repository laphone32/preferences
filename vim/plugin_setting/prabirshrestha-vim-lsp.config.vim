"""""""""""""""""""""""""""""""""""" vim-lsp & vim-lsp-settings

" 1. Map existing <Plug> hooks to vim-lsp
nmap <Plug>(go-to-definition-call)      <Plug>(lsp-definition)
nmap <Plug>(go-to-declaration-call)     <Plug>(lsp-declaration)
nmap <Plug>(go-to-type-definition-call) <Plug>(lsp-type-definition)
nmap <Plug>(go-to-implementation-call)  <Plug>(lsp-implementation)
nmap <Plug>(go-to-references-call)      <Plug>(lsp-references)
nmap <Plug>(go-to-diagnostic-prev-call) <Plug>(lsp-previous-diagnostic)
nmap <Plug>(go-to-diagnostics-next-call) <Plug>(lsp-next-diagnostic)

" Custom documentation and action hooks
nnoremap <Plug>(go-to-help-call)            :call LspGoToHelp()<CR>
nmap <Plug>(auto-code-action-call)      <Plug>(lsp-code-action)
nnoremap <Plug>(auto-fix-call)              :LspCodeAction quickfix<CR>
nmap <Plug>(auto-rename-call)           <Plug>(lsp-rename)
nnoremap <Plug>(auto-format-call)           :LspDocumentFormat<CR>
nnoremap <Plug>(auto-import-call)           :LspCodeAction source.organizeImports<CR>

" 2. Diagnostics Styling (matching your Coc style)
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 0
let g:lsp_diagnostics_float_cursor = 0
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_signs_enabled = 1
let g:lsp_diagnostics_signs_error = {'text': '>>'}
let g:lsp_diagnostics_signs_warning = {'text': '!!'}
let g:lsp_diagnostics_signs_information = {'text': '->'}
let g:lsp_diagnostics_signs_hint = {'text': '**'}

" Highlight reference symbols under cursor on hover
let g:lsp_document_highlight_enabled = 1

" 3. Floating window scrolling using C-f and C-b (matching Coc style)
function! LspHasFloatingWindow() abort
    try
        let l:Window = vital#lsp#import('VS.Vim.Window')
        let l:float_wins = l:Window.find({ winid -> l:Window.is_floating(winid) })
        return !empty(l:float_wins)
    catch
        return 0
    endtry
endfunction

nnoremap <expr> <C-f> LspHasFloatingWindow() ? lsp#scroll(+4) : "\<C-f>"
nnoremap <expr> <C-b> LspHasFloatingWindow() ? lsp#scroll(-4) : "\<C-b>"
inoremap <expr> <C-f> LspHasFloatingWindow() ? lsp#scroll(+4) : "\<Right>"
inoremap <expr> <C-b> LspHasFloatingWindow() ? lsp#scroll(-4) : "\<Left>"
vnoremap <expr> <C-f> LspHasFloatingWindow() ? lsp#scroll(+4) : "\<C-f>"
vnoremap <expr> <C-b> LspHasFloatingWindow() ? lsp#scroll(-4) : "\<C-b>"

" 4. Go to Help: Diagnostic detail or hover documentation (matching Coc style)
function! LspGoToHelp() abort
    " Check if there is a diagnostic under the cursor
    let l:diag = lsp#internal#diagnostics#under_cursor#get_diagnostic()
    if !empty(l:diag) && has_key(l:diag, 'message')
        " Format diagnostic nicely
        let l:severity = 'Diagnostic'
        if has_key(l:diag, 'severity')
            if l:diag['severity'] == 1
                let l:severity = 'Error'
            elseif l:diag['severity'] == 2
                let l:severity = 'Warning'
            elseif l:diag['severity'] == 3
                let l:severity = 'Information'
            elseif l:diag['severity'] == 4
                let l:severity = 'Hint'
            endif
        endif
        
        let l:source_info = ''
        if has_key(l:diag, 'source') && !empty(l:diag['source'])
            let l:source_info = ' [' . l:diag['source'] . ']'
        endif
        if has_key(l:diag, 'code') && !empty(l:diag['code'])
            let l:source_info .= ' (' . l:diag['code'] . ')'
        endif
        
        let l:title = '**[' . l:severity . ']' . l:source_info . '**'
        let l:lines = lsp#utils#_split_by_eol(l:diag['message'])
        let l:display_lines = [l:title, ''] + l:lines
        
        " Open in hover floating window
        call lsp#ui#vim#output#preview('', l:display_lines, {})
    else
        " Trigger standard LSP hover documentation
        execute 'LspHover'
    endif
endfunction

