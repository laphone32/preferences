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

    var _heightRatio: float

    var currentQuery: dict<any>
    var currentQueryType: qt.QueryType
    var previewTimer: number = -1

    var _originalBuffer: number = -1
    var _originalBufferWasEmpty: bool = v:false
    var _accepted: bool = v:false

    def _Position(): list<number>
        var height = winheight(0)
        return [height, winwidth(0) - 5, float2nr(height * this._heightRatio)]
    enddef

    def _MenuPosition(): dict<any>
        var [height, width, popupHeight] = this._Position()

        return {
            pos: 'botleft',
            line: height,
            maxheight: popupHeight,
            minheight: popupHeight,
            maxwidth: width,
            minwidth: width,
            title: this.currentQuery.title,
            onKey: this.ListOnKey,
        }
    enddef

    def _DialogPosition(): dict<any>
        var [height, width, popupHeight] = this._Position()

        return {
            pos: 'botleft',
            line: height - popupHeight,
            maxwidth: width,
            minwidth: width,
            title: this.currentQueryType.name,
            buffer: this.currentQuery.keyword,
            onType: this.OnDialogKey,
        }
    enddef

    def new(heightRatio: float)
        this._heightRatio = heightRatio

        this._buffer = rb.RichBuffer.new({
            name: '_listsBuffer_',
        })

        this._menu = mu.Menu.new({
            buffer: this._buffer.Get(),
            zindex: 200,
            onShow: () => {
              this._timer.Restart(100)
            },
            onHide: () => {
              this._timer.Restart(1000)
              if this.previewTimer != -1
                  timer_stop(this.previewTimer)
                  this.previewTimer = -1
              endif

              if !this._accepted && this._originalBuffer > 0
                  timer_start(0, (_) => {
                      if this._originalBufferWasEmpty
                          execute('silent! enew')
                      elseif bufexists(this._originalBuffer)
                          setbufvar(this._originalBuffer, '&buflisted', 1)
                          execute('silent! buffer ' .. this._originalBuffer)
                      else
                          execute('silent! enew')
                      endif
                  })
              endif
              this._originalBuffer = -1
              this._originalBufferWasEmpty = v:false
            },
        })

        this._dialog = ip.DoAsInput.new({
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

            this._buffer.Truncate(len(currentQueryType.lookup))

            var newTitle = currentQueryType.GetTitle(this.currentQuery.keyword)
            if this.currentQuery.title != newTitle
                this.currentQuery.title = newTitle
                popup_setoptions(this._menu.menuArea.Get(), { title: newTitle })
            endif

            this._menu.Update()
        })
    enddef

    def ListOnKey(key: string, line: number): bool
        var currentQueryType = this.currentQueryType

        if key ==# '/'
            this._dialog.Open(this._DialogPosition())
        elseif key ==# "\<right>"
            if currentQueryType.HasCustomKey(key)
                currentQueryType.OnListKey(key, line)
                this._TriggerPreview(1)
            else
                currentQueryType.NextMode(line)
            endif
        elseif key ==# "\<left>"
            if currentQueryType.HasCustomKey(key)
                currentQueryType.OnListKey(key, line)
                this._TriggerPreview(1)
            else
                currentQueryType.PrevMode(line)
            endif
        else
            if key ==# "\<cr>"
                this._accepted = v:true
                if this.previewTimer != -1
                    timer_stop(this.previewTimer)
                    this.previewTimer = -1
                endif
            endif

            currentQueryType.OnListKey(key, line)
            if currentQueryType.cursorLine > 0
                win_execute(this._menu.menuArea.Get(), 'cursor(' .. currentQueryType.cursorLine .. ', 1)')
                currentQueryType.cursorLine = -1
            endif
            if ["\<up>", 'k', "\<c-n>", "\<down>", 'j', "\<c-p>", "\<pageup>", "\<c-b>", "\<pagedown>", "\<c-f>", "\<home>", "\<end>", 'G']->index(key) >= 0
                this._TriggerPreview(line)
            elseif ['h', 'l']->index(key) >= 0
                this._TriggerPreview(1)
            endif
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

        if this._originalBuffer <= 0
            this._originalBuffer = bufnr('%')
            this._originalBufferWasEmpty = (bufname('%') == '')
        endif
        this._accepted = v:false

        this.currentQuery = query->copy()
        this.currentQueryType = queryType

        var currentQuery = this.currentQuery
        var currentQueryType = this.currentQueryType

        if currentQueryType.Start(query)
        else
            this._dialog.Open(this._DialogPosition())
        endif

        currentQuery.title = currentQueryType.GetTitle(query.keyword)

        this._menu.Open(this._MenuPosition())
    enddef

    def Resume()
        if this.currentQueryType != null_object
            this._menu.Show(this._MenuPosition())
        endif
    enddef

    def _TriggerPreview(line: number)
        if this.previewTimer != -1
            timer_stop(this.previewTimer)
        endif
        this.previewTimer = timer_start(100, (_) => {
            this.previewTimer = -1
            var cleared = v:false
            if line < len(this.currentQueryType.lookup)
                var data = this.currentQueryType.lookup[line]
                if !empty(data) && has_key(data, 'isdir') && data.isdir
                    cleared = v:true
                endif
            else
                cleared = v:true
            endif

            if cleared
                if !this._originalBufferWasEmpty && this._originalBuffer > 0 && bufexists(this._originalBuffer)
                    setbufvar(this._originalBuffer, '&buflisted', 1)
                    execute('silent! buffer ' .. this._originalBuffer)
                else
                    execute('silent! enew')
                endif
                redraw
                return
            endif
            this.currentQueryType.Preview(line)
        })
    enddef
endclass

