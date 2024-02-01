vim9script

import "./query.vim" as q
import "./asyncJob.vim" as aj

export class AsyncFindQuery extends q.QueryType
    var asyncJob: aj.AsyncJob

    def _LongPathMode(line: number): dict<any>
        var data = this.lookup[line]
        return ({
            text: data.lines.text,
            props: [
                { type: 'MatchStyle', location: mapnew(data.submatches, (x, v) => [line, v.start + 1, line, v.end + 1]) },
            ],
        })
    enddef

    def _FileNameMode(line: number): dict<any>
        return ({
            text: fnamemodify(this.lookup[line].lines.text, ':t')
        })
    enddef

    def new()
        this.name = ' find > '
        this.asyncJob = aj.AsyncJob.new({
            \ period: 300,
            \ threshold: 20,
        \ })

        this.modes = [
            this._LongPathMode,
            this._FileNameMode,
        ]

        this.currentMode = 1
    enddef

    def Start(query: dict<any>): bool
        var keyword = query->get('keyword', '')
        if len(keyword) > 0
            this.lookup = [{}]
            this.asyncJob.Start({
                \ cmd: ['/bin/sh', '-c', 'rg --files | rg --smart-case --json -- ' .. shellescape(keyword)],
                \ onData: this._OnAsyncRgData,
            \ })
        endif

        return len(keyword) > 0
    enddef

    def OnListKey(key: string, line: number)
        if line < len(this.lookup)
            if key ==# "\<cr>"
                execute 'silent! edit ' .. this.lookup[line].lines.text
            endif
        endif
    enddef

    def _OnAsyncRgData(messages: list<string>)
        var count = len(this.lookup)

        for message in messages
            var json = json_decode(message)
    #        {
    #        "type":"match",
    #        "data":{
    #            "path":{
    #                "text":"markets/internal/src/test/scala/com/folio/dealing/market/internal/replay/OrderBooksLogReplayEndToEndTest.scala"
    #            "},
    #            "lines":{
    #                "text":"      val msgProcessor2 = new RawFixToOrderBookMessageProcessor(testStoreReader, replayedBooks2)\n"
    #            "},
    #            "line_number":152,
    #            "absolute_offset":6108,
    #            "submatches":[{"match":{"text":"Reader"},"start":73,"end":79}]
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

