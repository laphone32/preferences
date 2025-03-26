vim9script

#import "./util.vim" as ut

export class ConsistentPopup
    var id: number
    var OnFilter: func(string): bool

#    var OnShow: ut.EventFunctionType = ut.DummyEventFunction
#    var OnHide: ut.EventFunctionType = ut.DummyEventFunction

    def Show(properties: dict<any> = {})
        popup_setoptions(this.id, properties->extend({ filter: this._Filter }))
#        this.OnShow()
        popup_show(this.id)
    enddef

    def Hide()
        popup_hide(this.id)
#        this.OnHide()
    enddef

    def _Filter(id: number, key: string): bool
        if this.OnFilter(key) || ["\<esc>", 'q']->index(key) >= 0
            this.Hide()
        endif

        return v:true
    enddef
endclass

