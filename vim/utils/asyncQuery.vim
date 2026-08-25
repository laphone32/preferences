vim9script

import "./queryType.vim" as qt
import "./asyncJob.vim" as aj

export class AsyncQuery extends qt.QueryType
    var asyncJob: aj.AsyncJob = aj.AsyncJob.new({
        onData: this._OnAsyncRgData,
    })

    def _OnAsyncRgData(message: string)
        if empty(message) | return | endif
        var json: dict<any> = {}
        try
            json = json_decode(message)
        catch
            return
        endtry

        if json->get('type', '') ==# 'match'
            var data = json.data
            data.lines.text = trim(data.lines.text, "\r\t\n", 2)
            if has_key(data, 'path') && has_key(data.path, 'text')
                data.filename = fnamemodify(data.path.text, ':t')
            elseif has_key(data, 'lines') && has_key(data.lines, 'text')
                data.filename = fnamemodify(data.lines.text, ':t')
            endif

            this.lookup->add(data)
            this.Refresh(len(this.lookup) - 1)
        elseif json->get('type', '') ==# 'summary'
            this.asyncJob.Stop()
        endif
    enddef
endclass

