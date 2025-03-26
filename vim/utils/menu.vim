vim9script

import "./consistentPopup.vim" as cp
import "./util.vim" as ut

class MenuArea extends cp.ConsistentPopup
    var buffer: number
    var OnKey: func(string, number): bool
    var OnShow: ut.EventFunctionType = ut.DummyEventFunction
    var OnHide: ut.EventFunctionType = ut.DummyEventFunction

    def new(properties: dict<any>)
        this.buffer = properties->get('buffer', -1)
        this.OnKey = properties->get('onKey', (k, l) => v:true )
        this.id = popup_menu(this.buffer, {
            hidden: v:true,
        }->extend(properties))

        this.OnFilter = this.KeyFilter
        this.OnShow = properties->get('onShow', ut.DummyEventFunction )
        this.OnHide = properties->get('onHide', ut.DummyEventFunction )
    enddef

    def Open(OnKey: func(string, number): bool = null_function)
        if OnKey != null_function
            this.OnKey = OnKey
        endif
        popup_setoptions(this.id, { firstline: 1 })
    enddef

    def Show(properties: dict<any> = {})
        this.OnShow()
        super.Show(properties)
    enddef

    def Hide()
        this.OnHide()
        super.Hide()
    enddef

    def Get(): number
        return this.id
    enddef

    def KeyFilter(key: string): bool
        if [
            \ "\<up>", 'k', "\<c-n>",
            \ "\<down>", 'j', "\<c-p>",
            \ "\<pageup>", "\<c-b>",
            \ "\<pagedown>", "\<c-f>",
            \ "\<home>",
            \ "\<end>", 'G',
        \ ]->index(key) >= 0
            win_execute(this.id, 'normal! ' .. key)
        endif

        return this.OnKey(key, getcurpos(this.id)[1])
    enddef
endclass

export class Menu extends cp.ConsistentPopup
    var menuArea: MenuArea

    def _MenuBarPosition(): dict<any>
        var menuId = this.menuArea.Get()
        var opts = popup_getoptions(menuId)
        var pos = popup_getpos(menuId)

        return {
            pos: 'topright',
            line: pos.line,
            col: pos.col + pos.width - 1,
            maxheight: 1,
            minheight: 1,
            zindex: opts.zindex + 1,
        }

    enddef

    def new(properties: dict<any>)
        this.menuArea = MenuArea.new(properties)
        var menuId = this.menuArea.Get()
        var opts = popup_getoptions(menuId)
        var pos = popup_getpos(menuId)

        this.id = popup_create(' 0 / 0 ', { hidden: v:true })
    enddef

    def OnFilter(key: string): bool
        var hide = this.menuArea.OnFilter(key)
        this.Update()

        return hide
    enddef

    def Open(properties: dict<any> = {})
        this.menuArea.Open(properties->get('onKey', null_function))
        this.Show(properties)
    enddef

    def Update()
        var id = this.menuArea.Get()
        popup_settext(this.id, ' ' .. getcurpos(id)[1] .. ' / ' .. line('$', id) .. ' ')
    enddef

    def Show(properties: dict<any>)
        this.menuArea.Show(properties)
        super.Show(this._MenuBarPosition())
    enddef

    def Hide()
        this.menuArea.Hide()
        super.Hide()
    enddef
endclass

