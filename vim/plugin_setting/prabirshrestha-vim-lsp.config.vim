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
nnoremap <Plug>(auto-code-action-call)  :call LspCodeActionWrapper('')<CR>
nnoremap <Plug>(auto-fix-call)          :call LspCodeActionWrapper('quickfix')<CR>
nmap <Plug>(auto-rename-call)           <Plug>(lsp-rename)
nmap <Plug>(auto-code-lens-call)        <Plug>(lsp-code-lens)
nnoremap <Plug>(auto-format-call)       :LspDocumentFormat<CR>
nnoremap <Plug>(auto-import-call)       :call LspCodeActionWrapper('source.organizeImports')<CR>
nnoremap <Plug>(normal-find-diagnostic-call) :LspDocumentDiagnostics<CR>

# 2. UI & Diagnostics Styling
g:lsp_code_action_ui = 'float'
g:lsp_preview_float = 1
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

# 4. Diagnostic selection & actions (matching Coc style)
def GetDiagnosticForCurrentPosition(): dict<any>
    var bufnr = bufnr('%')
    if !exists('*lsp#internal#diagnostics#state#_is_enabled_for_buffer') || !lsp#internal#diagnostics#state#_is_enabled_for_buffer(bufnr)
        return {}
    endif

    var uri = lsp#utils#get_buffer_uri(bufnr)
    var diags_by_server = lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(uri)
    var diags: list<dict<any>> = []
    for [server, response] in items(diags_by_server)
        var server_diags = get(get(response, 'params', {}), 'diagnostics', [])
        diags->extend(server_diags)
    endfor

    if empty(diags)
        return {}
    endif

    var ranges: list<list<number>> = []
    var idx = 0
    for d in diags
        var start_pos = lsp#utils#position#lsp_to_vim(bufnr, d.range.start)
        var end_pos = lsp#utils#position#lsp_to_vim(bufnr, d.range.end)
        ranges->add([start_pos[0], start_pos[1], end_pos[0], end_pos[1], idx])
        idx += 1
    endfor

    var matched = g:UnderCursorOrClosest(line('.'), col('.'), ranges)
    if empty(matched)
        return {}
    endif

    return diags[matched[4]]
enddef

def g:LspGoToHelp()
    var diag = GetDiagnosticForCurrentPosition()
    if !empty(diag) && has_key(diag, 'message')
        var severity = 'Diagnostic'
        var sev_num = get(diag, 'severity', 1)
        if sev_num == 1
            severity = 'Error'
        elseif sev_num == 2
            severity = 'Warning'
        elseif sev_num == 3
            severity = 'Information'
        elseif sev_num == 4
            severity = 'Hint'
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
        silent! execute 'LspHover'
    endif
enddef

def HandleCodeActionApply(chosen: dict<any>, bufnr: number)
    var ca = chosen.code_action
    if has_key(ca, 'edit')
        lsp#utils#workspace_edit#apply_workspace_edit(ca.edit)
    endif
    if has_key(ca, 'command')
        if type(ca.command) == v:t_string
            lsp#ui#vim#execute_command#_execute({
                server_name: chosen.server_name,
                command_name: ca.command,
                command_args: get(ca, 'arguments', v:null),
                sync: false,
                bufnr: bufnr
            })
        elseif type(ca.command) == v:t_dict
            lsp#ui#vim#execute_command#_execute({
                server_name: chosen.server_name,
                command_name: get(ca.command, 'command', ''),
                command_args: get(ca.command, 'arguments', v:null),
                sync: false,
                bufnr: bufnr
            })
        endif
    endif
enddef

def OnCodeActionResponse(data: dict<any>, server_name: string, bufnr: number, query: string, act_ctx: dict<any>)
    act_ctx.pending_count -= 1
    if !lsp#client#is_error(data.response) && !empty(get(data.response, 'result', []))
        var actions = data.response.result
        if !empty(query)
            actions = filter(actions, (idx, action) => get(action, 'kind', '') =~# '^' .. query)
        endif
        for action in actions
            act_ctx.actions->add({ server_name: server_name, code_action: action })
        endfor
    endif

    if act_ctx.pending_count > 0
        return
    endif

    if empty(act_ctx.actions)
        echo 'No code actions found'
        return
    endif

    # If single action with query, execute immediately (auto-fix behavior)
    if len(act_ctx.actions) == 1 && !empty(query)
        HandleCodeActionApply(act_ctx.actions[0], bufnr)
        echo 'Code action applied'
        return
    endif

    # Multiple actions: show popup menu
    var menu_items: list<string> = []
    for item in act_ctx.actions
        var title = printf('[%s] %s', item.server_name, item.code_action.title)
        if has_key(item.code_action, 'kind') && !empty(item.code_action.kind)
            title ..= ' (' .. item.code_action.kind .. ')'
        endif
        menu_items->add(title)
    endfor

    if lsp#utils#_has_popup_menu() && act_ctx.ui ==? 'float'
        lsp#internal#ui#popupmenu#open({
            title: 'Code actions',
            items: menu_items,
            pos: 'topleft',
            line: 'cursor+1',
            col: 'cursor',
            callback: (id, selected, ...rest) => {
                if selected > 0
                    HandleCodeActionApply(act_ctx.actions[selected - 1], bufnr)
                    doautocmd <nomodeline> User lsp_float_closed
                endif
            }
        })
    else
        var qp_items: list<dict<any>> = []
        for item in act_ctx.actions
            var title = printf('[%s] %s', item.server_name, item.code_action.title)
            qp_items->add({ title: title, item: item })
        endfor
        lsp#internal#ui#quickpick#open({
            items: qp_items,
            key: 'title',
            on_accept: (qp_data) => {
                lsp#internal#ui#quickpick#close()
                if !empty(qp_data.items)
                    HandleCodeActionApply(qp_data.items[0].item, bufnr)
                endif
            }
        })
    endif
enddef

def g:LspCodeActionWrapper(query: string = '')
    var diag = GetDiagnosticForCurrentPosition()
    if empty(diag)
        if empty(query)
            silent! execute 'LspCodeAction'
        else
            silent! execute 'LspCodeAction ' .. query
        endif
        return
    endif

    var server_names = filter(lsp#get_allowed_servers(), (idx, sname) => lsp#capabilities#has_code_action_provider(sname))
    if empty(server_names)
        lsp#utils#error('Code action not supported for ' .. &filetype)
        return
    endif

    var bufnr = bufnr('%')
    var line_range = lsp#utils#range#_get_current_line_range()
    var target_range = empty(diag) ? line_range : diag.range
    var target_context = {
        diagnostics: empty(diag) ? [] : [diag],
        only: ['', 'quickfix', 'refactor', 'refactor.extract', 'refactor.inline', 'refactor.rewrite', 'source', 'source.organizeImports']
    }

    var act_ctx = {
        pending_count: len(server_names),
        actions: [],
        ui: get(g:, 'lsp_code_action_ui', 'float')
    }

    for server_name in server_names
        lsp#send_request(server_name, {
            method: 'textDocument/codeAction',
            params: {
                textDocument: lsp#get_text_document_identifier(),
                range: target_range,
                context: target_context
            },
            sync: false,
            on_notification: (data) => OnCodeActionResponse(data, server_name, bufnr, query, act_ctx)
        })
    endfor
    echo 'Retrieving code actions ...'
enddef
