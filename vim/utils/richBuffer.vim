vim9script

export class RichBuffer
    var buffer: number
    var prop: dict<any>

    def _BufferAllocate(name: string): number
        var currentBufferNr = bufnr('%')
        var ret = bufnr(name, 1)

        execute 'buffer ' .. ret
        setlocal noswapfile nobuflisted bufhidden=hide buftype=nofile
        execute 'buffer ' .. currentBufferNr

        return ret
    enddef

    def _BufferClear(id: number)
        var currentBufferNr = bufnr('%')
        execute 'buffer ' .. id
        silent! normal! gg"_dG'
        execute 'buffer ' .. currentBufferNr
    enddef

    def new(properties: dict<string>)
        silent! this.buffer = this._BufferAllocate(properties->get('name', '_richBuffer_'))
        this.prop = { bufnr: this.buffer }
    enddef

    def Get(): number
        return this.buffer
    enddef

    def LineCount(): number
        return getbufinfo(this.buffer)[0].linecount
    enddef

    def Clear(from: number = 1, to: number = this.LineCount())
        this._BufferClear(this.buffer)
        prop_clear(from, to, this.prop)
    enddef

    def Refresh(properties: dict<string>)
        if && properties.to >= properties.from
            var line = properties.from

            while line <= properties.to
                RefreshLine(id, line, properties.f)
                line += 1
            endwhile
        endif
    enddef

    def RefreshLine(line: number, result: dict<any>)
        setbufline(this.buffer, line, result.text)
        for textprop in result->get('props', [])
            prop_add_list({bufnr: this.buffer, type: textprop.type}, textprop.location)
        endfor
    enddef

endclass

