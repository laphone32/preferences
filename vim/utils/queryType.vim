vim9script

export class QueryType
    var name: string = ' Query > '
    var lookup: list<any> = [{}]

    var modes: list<func(number): dict<any>>
    var currentMode: number

    var toRefresh: list<list<number>>



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
endclass

