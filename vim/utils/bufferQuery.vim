vim9script

import "./queryType.vim" as qt

export class BufferQuery extends qt.QueryType
    def _LongPathMode(line: number): dict<any>
        var data = this.lookup[line]
        var path = len(data.name) > 0 ? data.name : ' [NO NAME] '
        return ({
            text: (data.changed ? '+' : ' ') .. ' ' .. path,
            props: [
                { type: 'MatchStyle', location: [[line, data.match[1] + 3, line, data.match[2] + 3]] },
            ],
        })
    enddef

    def _FileNameMode(line: number): dict<any>
        var data = this.lookup[line]
        var path = fnamemodify((len(data.name) > 0 ? data.name : ' [NO NAME] '), ':t')
        return ({
            text: (data.changed ? '+' : ' ') .. ' ' .. path,
        })
    enddef

    def new()
        this.name = ' buffer > '
        this.modes = [
            this._LongPathMode,
            this._FileNameMode,
        ]

        this.currentMode = 0
    enddef

    def Start(query: dict<any>): bool
        var keyword = query->get('keyword')

        this.lookup = getbufinfo({ buflisted: v:true })->reduce((x, data) => {
            if getbufvar(data.bufnr, '&buftype') == 'terminal' || data.name =~ '^!'
                return x
            endif
            var path = len(data.name) > 0 ? data.name : ' [NO NAME] '
            var match = len(keyword) > 0 ? path->matchstrpos(keyword) : [0, -2, -2]
            if len(keyword) == 0 || match[1] >= 0
                data->extend({ match: match })
                x->add(data)
            endif
            return x
        }, [{}])

        this.Refresh()

        return v:true
    enddef

    def OnListKey(key: string, line: number)
        if line < len(this.lookup)
            if key ==# "\<cr>"
                execute 'silent! buffer ' .. this.lookup[line]['bufnr']
            endif
        endif
    enddef
endclass

