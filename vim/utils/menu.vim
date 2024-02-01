vim9script

import "./consistentPopup.vim" as cp

class MenuArea extends cp.ConsistentPopup
    var buffer: number
    var OnKey: func(string, number): bool

    def new(properties: dict<any>)
        this.buffer = properties->get('buffer', -1)
        this.OnKey = properties->get('onKey', (k, l) => v:true )
        this.id = popup_menu(this.buffer, {
            hidden: v:true,
        }->extend(properties))

        this.OnFilter = this.KeyFilter
        this.OnShow = properties->get('onShow', () => v:none )
        this.OnHide = properties->get('onHide', () => v:none )
    enddef

    def Open(properties: dict<any>)
        this.OnKey = properties->get('onKey', this.OnKey)
        popup_setoptions(this.id, { firstline: 1 }->extend(properties))
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

    def new(properties: dict<any>)
        this.menuArea = MenuArea.new(properties)
        var menuId = this.menuArea.Get()
        var opts = popup_getoptions(menuId)
        var pos = popup_getpos(menuId)

        this.id = popup_create(' 0 / 0 ', {
            \ pos: 'topright',
            \ line: pos.line,
            \ col: pos.col + pos.width - 1,
            \ maxheight: 1,
            \ minheight: 1,
            \ zindex: opts.zindex + 1,
            \ hidden: v:true,
          \ })
    enddef

    def OnFilter(key: string): bool
        var hide = this.menuArea.OnFilter(key)
        this.Update()

        return hide
    enddef

    def Open(properties: dict<any> = {})
        this.menuArea.Open(properties)
        this.Show()
    enddef

    def Update()
        var id = this.menuArea.Get()
        popup_settext(this.id, ' ' .. getcurpos(id)[1] .. ' / ' .. line('$', id) .. ' ')
    enddef

    def Show()
        this.menuArea.Show()
        super.Show()
    enddef

    def Hide()
        this.menuArea.Hide()
        super.Hide()
    enddef
endclass

