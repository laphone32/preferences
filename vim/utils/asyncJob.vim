vim9script

import "./util.vim" as ut

export class AsyncJob
    var _id: job
    var _OnData: func(string)

    def new(properties: dict<any>)
        this._id = null_job
        this._OnData = properties->get('onData', (_) => {
        })
    enddef

    def Start(properties: dict<any>)
        this.Stop()
        this._OnData = properties->get('onData', this._OnData)
        var opts: dict<any> = {
            in_io: 'null',
            out_cb: this._OnOut,
        }
        if properties->has_key('pty')
            opts.pty = properties.pty
        endif
        if properties->has_key('in_io')
            opts.in_io = properties.in_io
        endif
        this._id = job_start(properties->get('cmd', ['/bin/sh', '-c', "echo \'No command for async job\'"]), opts)
    enddef

    def _OnOut(channel: channel, message: string)
        this._OnData(message)
    enddef

    def Stop()
        if this._id != null_job
            this._id->job_stop()
            this._id = null_job
        endif
    enddef
endclass

