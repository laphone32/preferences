vim9script

export class DoAsInput
    var id: number
    var buffer: string
    var onType: func(string, string)

    def new(properties: dict<any>)
        this.buffer = properties->get('buffer', '')
        this.onType = properties->get('onType', (key, all) => {
            })
        this.id = popup_dialog(this.buffer, {
            minheight: 1,
            maxheight: 1,
            hidden: v:true,
            filter: this._KeyFilter
        }->extend(properties))
    enddef

    def _KeyFilter(id: number, key: string): bool
        var nr = char2nr(key)

        if nr >= 32 && nr <= 126
            this.buffer ..= key
        elseif key ==# "\<bs>"
            if len(this.buffer) > 1
                this.buffer = this.buffer[ : len(this.buffer) - 2]
            else
                this.buffer = ''
            endif
        elseif key ==# "\<esc>"
            popup_hide(this.id)
        endif

        popup_settext(this.id, this.buffer)
        this.onType(key, this.buffer)

        if key ==# "\<cr>"
            popup_hide(this.id)
        endif

        return v:true
    enddef

    def Open(properties = {})
        this.buffer = properties->get('buffer', '')
        this.onType = properties->get('onType', this.onType)

        popup_setoptions(this.id, properties)
        popup_settext(this.id, this.buffer)

        popup_show(this.id)
    enddef
endclass

