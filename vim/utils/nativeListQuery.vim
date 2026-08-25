vim9script

import "./queryType.vim" as qt

export class NativeListQuery extends qt.QueryType
    public var GetItems: func(dict<any>): list<dict<any>>

    def _BriefMode(line: number): dict<any>
        var data = this.lookup[line]
        var filename = get(data, 'filename', fnamemodify(data.path, ':t'))
        var type_tag = empty(data.type) ? 'QF' : data.type
        return ({
            text: printf(' [%s] %s:%d - %s', type_tag, filename, data.line, data.text),
        })
    enddef

    def _DetailedMode(line: number): dict<any>
        var data = this.lookup[line]
        var type_tag = empty(data.type) ? 'QF' : data.type
        return ({
            text: printf(' [%s] %s:%d:%d - %s', type_tag, data.path, data.line, data.col, data.text),
        })
    enddef

    def new(name: string, GetItems: func(dict<any>): list<dict<any>>)
        this.name = name
        this.GetItems = GetItems
        this.modes = [
            (line) => this._BriefMode(line),
            (line) => this._DetailedMode(line),
        ]
        this.currentMode = 0
    enddef

    def Start(query: dict<any>): bool
        var keyword = query->get('keyword', '')
        this.lookup = [{}]

        var raw_items = this.GetItems(query)

        var item_index = 1
        for item in raw_items
            var path = item.bufnr > 0 ? bufname(item.bufnr) : ''
            if empty(path) && has_key(item, 'filename')
                path = item.filename
            endif

            var lnum = max([get(item, 'lnum', 1), 1])
            var col = max([get(item, 'col', 1), 1])
            var text = trim(get(item, 'text', ''))
            var item_type = get(item, 'type', '')
            if empty(item_type) && has_key(item, 'valid') && !item.valid
                item_type = 'Info'
            endif

            var entry = {
                path: path,
                filename: fnamemodify(path, ':t'),
                line: lnum,
                col: col,
                text: text,
                type: item_type,
                idx: item_index
            }

            if empty(keyword) || entry.text =~? keyword || entry.path =~? keyword || entry.filename =~? keyword
                this.lookup->add(entry)
            endif

            item_index += 1
        endfor

        this.Refresh()
        return v:true
    enddef

    def OnListKey(key: string, line: number): bool
        if line < len(this.lookup)
            if key ==# "\<cr>"
                var data = this.lookup[line]
                if !empty(data) && !empty(data.path)
                    this.OpenFile(data.path, data.line, data.col)
                endif
                return v:true
            endif
        endif
        return v:true
    enddef
endclass
