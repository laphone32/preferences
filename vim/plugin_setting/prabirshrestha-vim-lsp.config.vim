vim9script

# vim-lsp & vim-lsp-settings

# 1. Map existing <Plug> hooks to vim-lsp
nmap <Plug>(go-to-definition-call)      <Plug>(lsp-definition)
nmap <Plug>(go-to-declaration-call)     <Plug>(lsp-declaration)
nmap <Plug>(go-to-type-definition-call) <Plug>(lsp-type-definition)
nmap <Plug>(go-to-implementation-call)  <Plug>(lsp-implementation)
nmap <Plug>(go-to-references-call)      <Plug>(lsp-references)
nmap <Plug>(go-to-diagnostic-prev-call) <Plug>(lsp-previous-diagnostic)
nmap <Plug>(go-to-diagnostics-next-call) <Plug>(lsp-next-diagnostic)

# Custom documentation and action hooks
nnoremap <Plug>(go-to-help-call)        :call LspGoToHelp()<CR>
nmap <Plug>(auto-code-action-call)      <Plug>(lsp-code-action)
nnoremap <Plug>(auto-fix-call)          :LspCodeAction quickfix<CR>
nmap <Plug>(auto-rename-call)           <Plug>(lsp-rename)
nnoremap <Plug>(auto-format-call)       :LspDocumentFormat<CR>
nnoremap <Plug>(auto-import-call)       :LspCodeAction source.organizeImports<CR>

# 2. Diagnostics Styling (matching your Coc style)
g:lsp_diagnostics_enabled = 1
g:lsp_diagnostics_echo_cursor = 0
g:lsp_diagnostics_float_cursor = 0
g:lsp_diagnostics_virtual_text_enabled = 0
g:lsp_diagnostics_signs_enabled = 1
g:lsp_diagnostics_signs_error = {text: '>>'}
g:lsp_diagnostics_signs_warning = {text: '!!'}
g:lsp_diagnostics_signs_information = {text: '->'}
g:lsp_diagnostics_signs_hint = {text: '**'}

# Highlight reference symbols under cursor on hover
g:lsp_document_highlight_enabled = 1

# 3. Floating window scrolling using C-f and C-b (matching Coc style)
def g:LspHasFloatingWindow(): bool
    try
        var Window = vital#lsp#import('VS.Vim.Window')
        var float_wins = Window.find((winid) => Window.is_floating(winid))
        return !empty(float_wins)
    catch
        return false
    endtry
enddef

nnoremap <expr> <C-f> g:LspHasFloatingWindow() ? lsp#scroll(+4) : "\<C-f>"
nnoremap <expr> <C-b> g:LspHasFloatingWindow() ? lsp#scroll(-4) : "\<C-b>"
inoremap <expr> <C-f> g:LspHasFloatingWindow() ? lsp#scroll(+4) : "\<Right>"
inoremap <expr> <C-b> g:LspHasFloatingWindow() ? lsp#scroll(-4) : "\<Left>"
vnoremap <expr> <C-f> g:LspHasFloatingWindow() ? lsp#scroll(+4) : "\<C-f>"
vnoremap <expr> <C-b> g:LspHasFloatingWindow() ? lsp#scroll(-4) : "\<C-b>"

# 4. Go to Help: Diagnostic detail or hover documentation (matching Coc style)
def g:LspGoToHelp()
    # Check if there is a diagnostic under the cursor
    var diag = lsp#internal#diagnostics#under_cursor#get_diagnostic()
    if !empty(diag) && has_key(diag, 'message')
        # Format diagnostic nicely
        var severity = 'Diagnostic'
        if has_key(diag, 'severity')
            if diag['severity'] == 1
                severity = 'Error'
            elseif diag['severity'] == 2
                severity = 'Warning'
            elseif diag['severity'] == 3
                severity = 'Information'
            elseif diag['severity'] == 4
                severity = 'Hint'
            endif
        endif
        
        var source_info = ''
        if has_key(diag, 'source') && !empty(diag['source'])
            source_info = ' [' .. diag['source'] .. ']'
        endif
        if has_key(diag, 'code') && !empty(diag['code'])
            source_info ..= ' (' .. diag['code'] .. ')'
        endif
        
        var title = '**[' .. severity .. ']' .. source_info .. '**'
        var lines = lsp#utils#_split_by_eol(diag['message'])
        var display_lines = [title, ''] + lines
        
        # Open in hover floating window
        lsp#ui#vim#output#preview('', display_lines, {})
    else
        # Trigger standard LSP hover documentation
        execute 'LspHover'
    endif
enddef
