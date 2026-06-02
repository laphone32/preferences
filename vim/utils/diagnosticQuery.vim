vim9script

import "./queryType.vim" as qt

export class DiagnosticQuery extends qt.QueryType
    def _BriefMode(line: number): dict<any>
        var data = this.lookup[line]
        var filename = fnamemodify(data.path, ':t')
        return ({
            text: printf(' [%s] %s:%d - %s', data.severity, filename, data.line, data.message),
        })
    enddef

    def _DetailedMode(line: number): dict<any>
        var data = this.lookup[line]
        return ({
            text: printf(' [%s] %s:%d:%d - %s', data.severity, data.path, data.line, data.col, data.message),
        })
    enddef

    def new()
        this.name = ' diagnostics > '
        this.modes = [
            this._BriefMode,
            this._DetailedMode,
        ]

        this.currentMode = 0
    enddef

    def Start(query: dict<any>): bool
        var keyword = query->get('keyword', '')
        this.lookup = [{}]

        if !exists('*lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_uri_and_server')
            this.Refresh()
            return v:true
        endif

        var raw_state = lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_uri_and_server()

        for [uri, servers] in items(raw_state)
            var path = lsp#utils#uri_to_path(uri)
            for [server, response] in items(servers)
                var diags = get(get(response, 'params', {}), 'diagnostics', [])
                for diag in diags
                    var severity = 'Error'
                    if diag.severity == 2
                        severity = 'Warning'
                    elseif diag.severity == 3
                        severity = 'Info'
                    elseif diag.severity == 4
                        severity = 'Hint'
                    endif

                    var start_line = diag.range.start.line + 1
                    var start_col = diag.range.start.character + 1

                    var entry = {
                        path: path,
                        line: start_line,
                        col: start_col,
                        message: diag.message,
                        severity: severity,
                        server: server
                    }

                    if len(keyword) == 0 || entry.message =~? keyword || entry.path =~? keyword
                        this.lookup->add(entry)
                    endif
                endfor
            endfor
        endfor

        this.Refresh()

        return v:true
    enddef

    def OnListKey(key: string, line: number)
        if line < len(this.lookup)
            if key ==# "\<cr>"
                var data = this.lookup[line]
                execute 'silent! edit ' .. data.path
                cursor(data.line, data.col)
            endif
        endif
    enddef

    def Preview(line: number)
        if line < len(this.lookup)
            var data = this.lookup[line]
            if !empty(data) && has_key(data, 'path')
                execute 'silent! edit ' .. data.path
                cursor(data.line, data.col)
                redraw
            endif
        endif
    enddef
endclass
