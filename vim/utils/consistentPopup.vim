vim9script

export class ConsistentPopup
    var id: number
    var OnFilter: func(string): bool
    var OnShow: func() = () => v:none
    var OnHide: func() = () => v:none

    def Show()
        popup_setoptions(this.id, { filter: this._Filter })
        this.OnShow()
        popup_show(this.id)
    enddef

    def Hide()
        popup_hide(this.id)
        this.OnHide()
    enddef

    def _Filter(id: number, key: string): bool
        if this.OnFilter(key) || ["\<esc>", 'q']->index(key) >= 0
            this.Hide()
        endif

        return v:true
    enddef
endclass

