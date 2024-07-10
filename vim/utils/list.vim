vim9script

import "./util.vim" as ut
import "./doAsInput.vim" as ip
import "./menu.vim" as mu
import "./richBuffer.vim" as rb
import "./queryType.vim" as qt

export class List
    var _buffer: rb.RichBuffer
    var _menu: mu.Menu
    var _dialog: ip.DoAsInput
    var _timer: ut.Timer

    var currentQuery: dict<any>
    var currentQueryType: qt.QueryType

    def new(height: number, width: number, popupHeight: number)

        this._buffer = rb.RichBuffer.new({
            name: '_listsBuffer_',
        })

        this._menu = mu.Menu.new({
            buffer: this._buffer.Get(),
            pos: 'botleft',
            line: height,
            maxheight: popupHeight,
            minheight: popupHeight,
            maxwidth: width,
            minwidth: width,
            zindex: 200,
            onShow: () => {
              this._timer.Restart(100)
            },
            onHide: () => {
              this._timer.Restart(1000)
            },
        })

        this._dialog = ip.DoAsInput.new({
            pos: 'botleft',
            line: height - popupHeight,
            maxwidth: width,
            minwidth: width,
            zindex: 250,
        })

        this._timer = ut.Timer.new(() => {
            var currentQueryType = this.currentQueryType
            var Render = currentQueryType.modes[currentQueryType.currentMode]

            for properties in currentQueryType.OnRefresh()
                var line = properties[0]
                var end = line + properties[1]

                while line < end
                    this._buffer.RefreshLine(line, Render(line))
                    line += 1
                endwhile
            endfor

            this._menu.Update()
        })
    enddef

    def ListOnKey(key: string, line: number): bool
        var currentQueryType = this.currentQueryType

        if key ==# '/'
            this._dialog.Open({
                title: currentQueryType.name,
                buffer: this.currentQuery.keyword,
            })
        elseif key ==# "\<right>"
            currentQueryType.NextMode(line)
        elseif key ==# "\<left>"
            currentQueryType.PrevMode(line)
        else
            currentQueryType.OnListKey(key, line)
        endif

        return key ==# "\<cr>"
    enddef

    def OnDialogKey(key: string, message: string)
        if key ==# "\<cr>" && message != this.currentQuery.keyword
            this.currentQuery.keyword = message
            this.Call(this.currentQueryType, this.currentQuery)
        endif
    enddef

    def Call(queryType: qt.QueryType, query: dict<any>)
        this._buffer.Clear()

        this.currentQuery = query->copy()
        this.currentQueryType = queryType

        var currentQuery = this.currentQuery
        var currentQueryType = this.currentQueryType

        currentQuery.title = currentQueryType.name .. query.keyword .. ' '

        if currentQueryType.Start(query)
        else
            this._dialog.Open({
                title: currentQuery.title,
                onType: this.OnDialogKey,
            })
        endif

        this._menu.Open({
            title: currentQuery.title,
            onKey: this.ListOnKey,
        })
    enddef

    def Resume()
        if this.currentQueryType != null_object
            this._menu.Show()
        endif
    enddef
endclass

