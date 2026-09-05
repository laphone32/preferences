vim9script

if empty(prop_type_get('InputCursorStyle'))
    silent! prop_type_add('InputCursorStyle', {highlight: 'Directory', override: v:true})
else
    silent! prop_type_change('InputCursorStyle', {highlight: 'Directory', override: v:true})
endif

export class DoAsInput
    var id: number
    var buffer: string
    var pos: number
    var onType: func(string, string)

    def new(properties: dict<any>)
        this.buffer = properties->get('buffer', '')
        this.pos = len(this.buffer)
        this.onType = properties->get('onType', (key, all) => {
            })
        this.id = popup_dialog('', {
            minheight: 1,
            maxheight: 1,
            hidden: v:true,
            filter: this._KeyFilter
        }->extend(properties))
    enddef

    def _Render()
        var display = (this.pos > 0 ? this.buffer[ : this.pos - 1] : '')
                    .. '▏'
                    .. this.buffer[this.pos : ]
        popup_settext(this.id, [{
            text: display,
            props: [{
                col: this.pos + 1,
                length: len('▏'),
                type: 'InputCursorStyle',
            }],
        }])
    enddef

    def _KeyFilter(id: number, key: string): bool
        var handled = v:true

        if key ==# "\<Left>" || key ==# "\<C-b>"
            this.pos = max([0, this.pos - 1])
        elseif key ==# "\<Right>" || key ==# "\<C-f>"
            this.pos = min([len(this.buffer), this.pos + 1])
        elseif key ==# "\<Home>" || key ==# "\<C-a>"
            this.pos = 0
        elseif key ==# "\<End>" || key ==# "\<C-e>"
            this.pos = len(this.buffer)
        elseif key ==# "\<bs>" || key ==# "\<C-h>"
            if this.pos > 0
                var before = this.pos > 1 ? this.buffer[ : this.pos - 2] : ''
                var after = this.buffer[this.pos : ]
                this.buffer = before .. after
                this.pos -= 1
            endif
        elseif key ==# "\<Del>" || key ==# "\<C-d>"
            if this.pos < len(this.buffer)
                var before = this.pos > 0 ? this.buffer[ : this.pos - 1] : ''
                var after = this.buffer[this.pos + 1 : ]
                this.buffer = before .. after
            endif
        elseif key ==# "\<C-u>"
            this.buffer = ''
            this.pos = 0
        elseif key ==# "\<C-w>"
            if this.pos > 0
                var before = this.buffer[ : this.pos - 1]
                var trimmed = substitute(before, '\s*\k*$', '', '')
                this.buffer = trimmed .. this.buffer[this.pos : ]
                this.pos = len(trimmed)
            endif
        elseif key ==# "\<esc>"
            popup_hide(this.id)
            return v:true
        elseif key ==# "\<cr>"
            popup_hide(this.id)
            this.onType(key, this.buffer)
            return v:true
        else
            var nr = char2nr(key)
            if nr >= 32 && nr <= 126
                var before = this.pos > 0 ? this.buffer[ : this.pos - 1] : ''
                var after = this.buffer[this.pos : ]
                this.buffer = before .. key .. after
                this.pos += 1
            else
                handled = v:false
            endif
        endif

        if handled
            this._Render()
            this.onType(key, this.buffer)
        endif

        return v:true
    enddef

    def Open(properties = {})
        this.buffer = properties->get('buffer', '')
        this.pos = len(this.buffer)
        this.onType = properties->get('onType', this.onType)

        popup_setoptions(this.id, properties)
        this._Render()

        popup_show(this.id)
    enddef
endclass

