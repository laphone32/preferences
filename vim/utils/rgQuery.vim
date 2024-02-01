vim9script

import "./query.vim" as q
import "./asyncJob.vim" as aj

export class AsyncRgQuery extends q.QueryType
    var asyncJob: aj.AsyncJob

    def _LongPathMode(line: number): dict<any>
        var data = this.lookup[line]
        var path = data.path.text
        return ({
            text: path .. ' ' .. data.lines.text,
            props: [
                { type: 'FileStyle', location: [[line, 1, line, len(path) + 1]] },
                { type: 'MatchStyle', location: mapnew(data.submatches, (x, v) => [line, len(path) + 1 + v.start + 1, line, len(path) + 1 + v.end + 1]) },
            ],
        })
    enddef

    def _FileNameMode(line: number): dict<any>
        var data = this.lookup[line]
        var path = fnamemodify(data.path.text, ':t')
        return ({
            text: path .. ' ' .. data.lines.text,
            props: [
                { type: 'FileStyle', location: [[line, 1, line, len(path) + 1]] },
                { type: 'MatchStyle', location: mapnew(data.submatches, (x, v) => [line, len(path) + 1 + v.start + 1, line, len(path) + 1 + v.end + 1]) },
            ],
        })
    enddef

    def new()
        this.name = ' rg > '
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
                \ cmd: ['/bin/sh', '-c', 'rg --smart-case --json -- ' .. shellescape(keyword)],
                \ onData: this._OnAsyncRgData,
            \ })
        endif

        return len(keyword) > 0
    enddef

    def OnListKey(key: string, line: number)
        if line < len(this.lookup)
            if key ==# "\<cr>"
                var data = this.lookup[line]
                execute 'silent! edit ' .. data.path.text
                silent! cursor(data.line_number, data.submatches[0].start)
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

