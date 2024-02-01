vim9script

import "./consistentPopup.vim" as cp

export class DoAsInput extends cp.ConsistentPopup
    var buffer: string
    var onType: func(string, string)

    def new(properties: dict<any>)
        this.buffer = properties->get('buffer', '')
        this.onType = properties->get('onType', (key, all) => {
            })
        this.id = popup_dialog(this.buffer, {
            \ minheight: 1,
            \ maxheight: 1,
            \ hidden: v:true,
        }->extend(properties))

        this.OnFilter = this.KeyFilter
    enddef

    def KeyFilter(key: string): bool
        var nr = char2nr(key)

        if nr >= 32 && nr <= 126
            this.buffer ..= key
        elseif key ==# "\<bs>"
            if len(this.buffer) > 1
                this.buffer = this.buffer[ : len(this.buffer) - 2]
            else
                this.buffer = ''
            endif
        endif

        popup_settext(this.id, this.buffer)
        this.onType(key, this.buffer)

        return key ==# "\<cr>"
    enddef

    def Open(properties = {})
        this.buffer = properties->get('buffer', '')
        this.onType = properties->get('onType', this.onType)

        popup_setoptions(this.id, properties)
        popup_settext(this.id, this.buffer)

        super.Show()
    enddef
endclass

