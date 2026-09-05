vim9script

import "./util.vim" as ut
import "./doAsInput.vim" as ip
import "./menu.vim" as mu
import "./richBuffer.vim" as rb
import "./queryType.vim" as qt

var saved_t_ve: string = ''
var saved_guicursor: string = ''

def HideCursor()
    if has('gui_running')
        if empty(saved_guicursor)
            saved_guicursor = &guicursor
        endif
        &guicursor = 'a:hor0'
    else
        if empty(saved_t_ve)
            saved_t_ve = &t_ve
        endif
        &t_ve = ''
        echoraw(&t_vi != '' ? &t_vi : "\<Esc>[?25l")
    endif
enddef

def ShowCursor()
    if has('gui_running')
        if !empty(saved_guicursor)
            &guicursor = saved_guicursor
            saved_guicursor = ''
        else
            execute 'set guicursor&'
        endif
    else
        if !empty(saved_t_ve)
            &t_ve = saved_t_ve
            echoraw(saved_t_ve)
            saved_t_ve = ''
        else
            execute 'set t_ve&'
            echoraw("\<Esc>[?25h")
        endif
    endif
enddef

augroup ListCursorGuard
    autocmd!
    autocmd VimLeavePre * ShowCursor()
augroup END

export class List
    var _buffer: rb.RichBuffer
    var _menu: mu.Menu
    var _dialog: ip.DoAsInput
    var _timer: ut.Timer

    var _heightRatio: float
    var _dirty: bool = v:false

    var currentQuery: dict<any>
    var currentQueryType: qt.QueryType

    def MarkDirty()
        this._dirty = v:true
    enddef

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

    def _RestoreCursor()
        var currentQueryType = this.currentQueryType
        if currentQueryType != null_object && currentQueryType.cursorLine > 0
            var win_id = this._menu.menuArea.Get()
            var target = currentQueryType.cursorLine
            if line('$', win_id) >= target
                var [height, width, popupHeight] = this._Position()
                var fl = max([1, target - float2nr(popupHeight / 2)])
                popup_setoptions(win_id, { firstline: fl })
                win_execute(win_id, 'cursor(' .. target .. ', 1)')
                currentQueryType.cursorLine = -1
            endif
        endif
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
              HideCursor()
              this._timer.Restart(100)
            },
            onHide: () => {
              ShowCursor()
              this._timer.Stop()
              if this.currentQueryType != null_object
                  this.currentQueryType.cursorLine = -1
              endif
            },
        })

        this._dialog = ip.DoAsInput.new({
            zindex: 250,
        })

        this._timer = ut.Timer.new(() => {
            var currentQueryType = this.currentQueryType
            if currentQueryType == null_object
                return
            endif
            var Render = currentQueryType.modes[currentQueryType.currentMode]

            for properties in currentQueryType.OnRefresh()
                var line = properties[0]
                var count = properties[1]
                if count <= 0 | continue | endif
                var end = line + count

                var texts = []
                var props_by_type: dict<list<any>> = {}
                var curr = line
                while curr < end
                    if curr < len(currentQueryType.lookup)
                        var res = Render(curr)
                        texts->add(res.text)
                        for textprop in res->get('props', [])
                            var ptype = textprop.type
                            if !has_key(props_by_type, ptype)
                                props_by_type[ptype] = []
                            endif
                            props_by_type[ptype]->extend(textprop.location)
                        endfor
                    endif
                    curr += 1
                endwhile

                if !empty(texts)
                    this._buffer.SetLines(line, texts)
                    for [ptype, locs] in items(props_by_type)
                        this._buffer.AddProps(ptype, locs)
                    endfor
                endif
            endfor

            this._buffer.Truncate(len(currentQueryType.lookup))

            var newTitle = currentQueryType.GetTitle(this.currentQuery.keyword)
            if this.currentQuery.title != newTitle
                this.currentQuery.title = newTitle
                popup_setoptions(this._menu.menuArea.Get(), { title: newTitle })
            endif

            this._RestoreCursor()
            this._menu.Update()
        })
    enddef

    def ListOnKey(key: string, line: number): bool
        var currentQueryType = this.currentQueryType
        var shouldClose: bool = v:true

        if key ==# '/'
            this._dialog.Open(this._DialogPosition())
            return v:false
        elseif key ==# 'p'
            currentQueryType.Preview(line)
            return v:false
        elseif key ==# 'r'
            if currentQueryType.HasCustomKey(key)
                shouldClose = currentQueryType.OnListKey(key, line)
            else
                this.Refresh()
                shouldClose = v:false
            endif
        elseif key ==# "\<right>"
            if currentQueryType.HasCustomKey(key)
                shouldClose = currentQueryType.OnListKey(key, line)
            else
                currentQueryType.NextMode(line)
                shouldClose = v:false
            endif
        elseif key ==# "\<left>"
            if currentQueryType.HasCustomKey(key)
                shouldClose = currentQueryType.OnListKey(key, line)
            else
                currentQueryType.PrevMode(line)
                shouldClose = v:false
            endif
        else
            shouldClose = currentQueryType.OnListKey(key, line)
        endif

        this._RestoreCursor()

        return key ==# "\<cr>" && shouldClose
    enddef

    def OnDialogKey(key: string, message: string)
        if key ==# "\<cr>" && message != this.currentQuery.keyword
            this.currentQuery.keyword = message
            this.Call(this.currentQueryType, this.currentQuery)
        endif
    enddef

    def Call(queryType: qt.QueryType, query: dict<any>)
        this._dirty = v:false
        this._buffer.Clear()

        this.currentQuery = query->copy()
        this.currentQueryType = queryType

        var currentQuery = this.currentQuery
        var currentQueryType = this.currentQueryType

        currentQueryType.cursorLine = -1
        currentQueryType.toRefresh = []
        if currentQueryType.Start(query)
        else
            this._dialog.Open(this._DialogPosition())
        endif

        currentQuery.title = currentQueryType.GetTitle(query.keyword)

        this._menu.Open(this._MenuPosition())
        this._RestoreCursor()
    enddef

    def Refresh()
        var last_line = getcurpos(this._menu.menuArea.Get())[1]
        this._buffer.Clear()

        var currentQuery = this.currentQuery
        var currentQueryType = this.currentQueryType

        currentQueryType.toRefresh = []
        var refreshQuery = currentQuery->copy()
        refreshQuery.keepPath = v:true
        currentQueryType.Start(refreshQuery)

        var newTitle = currentQueryType.GetTitle(currentQuery.keyword)
        if currentQuery.title != newTitle
            currentQuery.title = newTitle
            popup_setoptions(this._menu.menuArea.Get(), { title: newTitle })
        endif

        var target_line = currentQueryType.cursorLine > 0 ? currentQueryType.cursorLine : last_line
        currentQueryType.cursorLine = target_line > 0 ? target_line : 1
        this._RestoreCursor()
    enddef

    def Resume()
        if this.currentQueryType != null_object
            if this._dirty
                this._dirty = v:false
                this.Refresh()
            endif
            this._menu.Show(this._MenuPosition())
        endif
    enddef
endclass


