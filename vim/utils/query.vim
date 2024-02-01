vim9script

export class QueryType
    var name: string = ' Query > '
    var lookup: list<any> = [{}]
    var modes: list<func(number): dict<any>>
    var toRefresh: list<dict<any>>
    var currentMode: number

    def Start(query: dict<any>): bool
        return v:true
    enddef

    def OnListKey(key: string, line: number)
    enddef

    def NextMode()
        if this.currentMode < len(this.modes) - 1
            this.currentMode += 1
            this.toRefresh->add({
                from: 1,
                len: len(this.lookup) - 1,
                buffer: this.modes[this.currentMode],
            })
        endif
    enddef

    def PrevMode()
        if this.currentMode > 0
            this.currentMode -= 1
            this.toRefresh->add({
                from: 1,
                len: len(this.lookup) - 1,
                buffer: this.modes[this.currentMode],
            })
        endif
    enddef

    def OnRefresh(): list<dict<any>>
        var tmp = this.toRefresh
        this.toRefresh = [{}]
        return tmp
    enddef
endclass

