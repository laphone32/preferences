vim9script

import "./consistentPopup.vim" as cp
import "./util.vim" as ut

export class Term extends cp.ConsistentPopup
    var buffer: number

    def new(properties: dict<any> = {})
        this._CreateBuffer(null_job, 0)
    enddef

    def _CreateBuffer(job: job, status: number)
        this.buffer = term_start([&shell], {
            hidden: 1,
            term_finish: 'close',
            exit_cb: this._CreateBuffer
        })
    enddef

    def Show(properties: dict<any> = {})
        this.id = this.buffer->popup_create({
            border: [],
            pos: 'center',
            title: 'Terminal',
            minwidth: winwidth(0) - 2,
            minheight: winheight(0) - 1,
        }->extend(properties))
    enddef

    def Hide()
        popup_close(this.id)
        this.id = 0
    enddef

    def Kill()
        this.Hide()
        execute "bw! " .. this.buffer
    enddef
endclass


