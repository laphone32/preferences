vim9script

import "./asyncQuery.vim" as aq
import "./asyncJob.vim" as aj

export class AsyncFindQuery extends aq.AsyncQuery
    def _LongPathMode(line: number): dict<any>
        var data = this.lookup[line]
        return ({
            text: data.lines.text,
            props: [
                { type: 'MatchStyle', location: mapnew(data.submatches, (x, v) => [line, v.start + 1, line, v.end + 1]) },
            ],
        })
    enddef

    def _FileNameMode(line: number): dict<any>
        return ({
            text: fnamemodify(this.lookup[line].lines.text, ':t')
        })
    enddef

    def new()
        this.name = ' find > '

        this.modes = [
            this._LongPathMode,
            this._FileNameMode,
        ]

        this.currentMode = 0
    enddef

    def Start(query: dict<any>): bool
        var keyword = query->get('keyword', '')
        if len(keyword) > 0
            this.lookup = [{}]
            this.asyncJob.Start({
                \ cmd: ['/bin/sh', '-c', 'rg --files | rg --smart-case --fixed-strings --json -- ' .. shellescape(keyword)],
            \ })
        endif

        return len(keyword) > 0
    enddef

    def OnListKey(key: string, line: number)
        if line < len(this.lookup)
            if key ==# "\<cr>"
                execute 'silent! edit ' .. fnameescape(this.lookup[line].lines.text)
            endif
        endif
    enddef

    def Preview(line: number)
        if line < len(this.lookup)
            var data = this.lookup[line]
            if !empty(data) && has_key(data, 'lines')
                execute 'silent! edit ' .. fnameescape(data.lines.text)
                redraw
            endif
        endif
    enddef
endclass

