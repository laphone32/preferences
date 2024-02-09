vim9script

import "./util.vim" as ut
import "./doAsInput.vim" as ip
import "./menu.vim" as mu
import "./richBuffer.vim" as rb
import "./query.vim" as q

export class List
    var _buffer: rb.RichBuffer
    var _menu: mu.Menu
    var _dialog: ip.DoAsInput
    var _timer: ut.Timer

    var currentQuery: dict<any>
    var currentQueryType: q.QueryType

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
            this._RefreshBuffer(this.currentQueryType.OnRefresh())
            this._menu.Update()
        })
    enddef

    def _RefreshBuffer(propertieList: list<dict<any>>)
        for properties in propertieList
            var line = properties->get('from', 1)
            var end = line + properties->get('len')

            var Render = properties->get('buffer', (x) => ({ text: '' }))
            while line < end
                this._buffer.RefreshLine(line, Render(line))
                line += 1
            endwhile
        endfor
    enddef

    def ListOnKey(key: string, line: number): bool
        var currentQueryType = this.currentQueryType
        if key ==# '/'
            this._dialog.Open({
                title: this.currentQuery.title,
            })
        elseif key ==# "\<right>"
            currentQueryType.NextMode()
        elseif key ==# "\<left>"
            currentQueryType.PrevMode()
        else
            currentQueryType.OnListKey(key, line)
        endif

        return key ==# "\<cr>"
    enddef

    def OnDialogKey(key: string, message: string)
        if key ==# "\<cr>" && message !=# this.currentQuery.keyword
            this.currentQuery.keyword = message
            this.Call(this.currentQueryType, this.currentQuery)
        endif
    enddef

    def Call(queryType: q.QueryType, query: dict<any>)
        this._buffer.Clear()

        this.currentQuery = query->copy()
        this.currentQueryType = queryType

        this.currentQuery.title = this.currentQueryType.name .. query.keyword .. ' '

        if this.currentQueryType.Start(query)
        else
            this._dialog.Open({
                title: this.currentQuery.title,
                onType: this.OnDialogKey,
            })
        endif

        this._menu.Open({
            title: this.currentQuery.title,
            onKey: this.ListOnKey,
        })
    enddef

    def Resume()
        this._menu.Open()
    enddef
endclass

