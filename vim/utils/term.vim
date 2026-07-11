vim9script

import "./consistentPopup.vim" as cp
import "./util.vim" as ut

export class Term extends cp.ConsistentPopup
    var buffer: number
    var cmd: list<string>
    var title: string
    var closeOnEscCmd: string
    var width: number
    var saved_ambiwidth: string

    def new(cmd: list<string> = [&shell], title: string = 'Terminal', closeOnEscCmd: string = '', width: number = 0)
        this.cmd = cmd
        this.title = title
        this.closeOnEscCmd = closeOnEscCmd
        this.width = width
        this.saved_ambiwidth = ''
        this._CreateBuffer(null_job, 0)
    enddef

    def _CreateBuffer(job: job, status: number)
        # Use exact width and height so popup_create doesn't trigger a resize
        var cols = this.width > 0 ? min([&columns - 4, this.width]) : &columns - 4
        var rows = &lines - 4
        
        this.buffer = term_start(this.cmd, {
            hidden: 1,
            term_finish: 'close',
            exit_cb: this._CreateBuffer,
            term_rows: rows,
            term_cols: cols,
        })
    enddef

    def Show(properties: dict<any> = {})
        this.saved_ambiwidth = &ambiwidth
        &ambiwidth = 'single'

        # The popup minwidth/minheight must EXACTLY match the term_cols/term_rows
        var cols = this.width > 0 ? min([&columns - 4, this.width]) : &columns - 4
        var rows = &lines - 4
        this.id = this.buffer->popup_create({
            border: [],
            pos: 'center',
            title: this.title,
            minwidth: cols,
            maxwidth: cols,
            minheight: rows,
            maxheight: rows,
            wrap: v:false,
        }->extend(properties))

        if !empty(this.closeOnEscCmd)
            win_execute(this.id, $'tnoremap <buffer> <esc> <c-w>:{this.closeOnEscCmd}<cr>')
        endif
    enddef

    def Hide()
        if this.id > 0
            popup_close(this.id)
            this.id = 0
        endif
        if !empty(this.saved_ambiwidth)
            &ambiwidth = this.saved_ambiwidth
            this.saved_ambiwidth = ''
        endif
    enddef

    def Kill()
        this.Hide()
        if this.buffer > 0 && bufexists(this.buffer)
            execute "bw! " .. this.buffer
        endif
    enddef
endclass


