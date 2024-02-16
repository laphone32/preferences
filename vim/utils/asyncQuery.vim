vim9script

import "./queryType.vim" as q
import "./asyncJob.vim" as aj

export class AsyncQuery extends q.QueryType
    var asyncJob: aj.AsyncJob = aj.AsyncJob.new({
        onData: this._OnAsyncRgData,
    })

    def _OnAsyncRgData(messages: list<string>)
        var count = len(this.lookup)

        for message in messages
            var json = json_decode(message)
    #        {
    #        "type":"match",
    #        "data":{
    #            "path":{
    #                "text":"path/to/the/file.type"
    #            "},
    #            "lines":{
    #                "text":"      the matching text here\n"
    #            "},
    #            "line_number":152,
    #            "absolute_offset":6108,
    #            "submatches":[{"match":{"text":"matching"},"start":73,"end":79}]
    #        }
    #        }
            if json.type == 'match'
                json.data.lines.text = trim(json.data.lines.text, "\r\t\n", 2)

                this.lookup->add(json.data)
            elseif json.type == 'summary'
                this.asyncJob.Stop()
            endif
        endfor
        this.toRefresh->add({
            from: count,
            len: len(this.lookup) - count,
            buffer: this.modes[this.currentMode],
        })
    enddef
endclass

