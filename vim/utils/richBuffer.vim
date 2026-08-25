vim9script

export class RichBuffer
    var buffer: number
    var prop: dict<any>

    def _BufferAllocate(name: string): number
        var ret = bufnr(name, 1)

        if ret > 0
            bufload(ret)
            setbufvar(ret, '&swapfile', 0)
            setbufvar(ret, '&buflisted', 0)
            setbufvar(ret, '&bufhidden', 'hide')
            setbufvar(ret, '&buftype', 'nofile')
        endif

        return ret
    enddef

    def _BufferClear(id: number)
        deletebufline(id, 1, '$')
    enddef

    def new(properties: dict<string>)
        silent! this.buffer = this._BufferAllocate(properties->get('name', '_richBuffer_'))
        this.prop = { bufnr: this.buffer }
    enddef

    def Get(): number
        return this.buffer
    enddef

    def LineCount(): number
        var info = getbufinfo(this.buffer)
        return empty(info) ? 0 : info[0].linecount
    enddef

    def Clear(from: number = 1, to: number = 0)
        this._BufferClear(this.buffer)
        var end_line = to > 0 ? to : this.LineCount()
        prop_clear(from, end_line, this.prop)
    enddef

    def Truncate(from: number)
        var count = this.LineCount()
        if count >= from
            deletebufline(this.buffer, from, '$')
        endif
    enddef

    def SetLines(start_line: number, texts: list<string>)
        if empty(texts) | return | endif
        var count = this.LineCount()
        if start_line > count + 1
            var gap = repeat([''], start_line - count - 1)
            appendbufline(this.buffer, count, gap)
            count = start_line - 1
        endif
        if start_line <= count || count == 0
            setbufline(this.buffer, start_line, texts)
        else
            appendbufline(this.buffer, count, texts)
        endif
    enddef

    def AddProps(type: string, locations: list<any>)
        if !empty(locations)
            prop_add_list({ bufnr: this.buffer, type: type }, locations)
        endif
    enddef

    def RefreshLine(line: number, result: dict<any>)
        this.SetLines(line, [result.text])
        for textprop in result->get('props', [])
            this.AddProps(textprop.type, textprop.location)
        endfor
    enddef

endclass

