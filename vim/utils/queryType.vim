vim9script

export class QueryType
    var name: string = ' Query > '
    var lookup: list<any> = [{}]

    var modes: list<func(number): dict<any>>
    var currentMode: number

    var toRefresh: list<list<number>>



    public var cursorLine: number = -1

    def GetTitle(keyword: string): string
        return this.name .. keyword .. ' '
    enddef

    def HasCustomKey(key: string): bool
        return v:false
    enddef

    def PreviewFile(path: string, line_num: number = 1, col: number = 1)
        var was_listed = buflisted(path)
        execute 'silent! edit ' .. fnameescape(path)
        if !was_listed
            setlocal nobuflisted
            setlocal noswapfile
        endif
        cursor(line_num, col)
        redraw
    enddef

    def OpenFile(path: string, line_num: number = 1, col: number = 1)
        execute 'silent! edit ' .. fnameescape(path)
        if isdirectory(path)
            setlocal nobuflisted
            setlocal noswapfile
        else
            setlocal buflisted
            setlocal swapfile
        endif
        cursor(line_num, col)
    enddef

    def Start(query: dict<any>): bool
        return v:true
    enddef

    def OnListKey(key: string, line: number)
    enddef

    def NextMode(line: number)
        if this.currentMode < len(this.modes) - 1
            this.currentMode += 1
            this.Refresh()
        endif
    enddef

    def PrevMode(line: number)
        if this.currentMode > 0
            this.currentMode -= 1
            this.Refresh()
        endif
    enddef

    def Refresh(start: number = 1)
        this.toRefresh->add([start, len(this.lookup) - start])
    enddef

    def OnRefresh(): list<list<number>>
        var tmp = this.toRefresh
        this.toRefresh = []
        return tmp
    enddef

    def Preview(line: number)
    enddef
endclass

