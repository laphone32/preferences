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
        var result = getbufinfo({ buflisted: v:true })

        var keyword = query->get('keyword')
        if len(keyword) > 0
            result = result->reduce((x, data) => {
                var pos = data->get('name', keyword)->matchstrpos(keyword)
                if pos[1] != -1
                    data->extend({ match: pos })
                    x->add(data)
                endif
                return x
            }, [{}])
        else
            result = result->reduce((x, data) => {
                data->extend({ match: [0, -2, -2] })
                x->add(data)
                return x
            }, [{}])
        endif

        this.lookup = result
        this.Refresh()

        return v:true
    enddef

    def OnListKey(key: string, line: number)
        if line < len(this.lookup)
            if key ==# "\<cr>"
                var data = this.lookup[line]
                execute 'silent! edit ' .. data.name
            endif
        endif
    enddef
endclass

