
call LoadConfig('utils/asyncJob.vim')
call LoadConfig('utils/doAsInput.vim')
call LoadConfig('utils/listMenu.vim')

let s:height = winheight(0)
let s:width = winwidth(0)
let s:popupHeight = float2nr(s:height * 0.4)

silent! let s:buffer = BufferAllocate('_listsBuffer_')
let s:lookup = [{}]

let s:menuId = ListMenuInit(s:buffer, #{
    \ pos: 'botleft',
    \ line: s:height,
    \ height: s:popupHeight,
    \ width: s:width,
  \ })
let s:jobId = AsyncJobInit(#{
    \ out_mode: 'JSON',
    \ threshold: s:popupHeight * 2,
  \ })
let s:dialogId = DoAsInputInit(#{
    \ pos: 'botleft',
    \ line: s:height - s:popupHeight,
    \ width: s:width,
    \ zindex: 201,
  \ })

highlight ListMatchGroup ctermfg=green guifg=green
call prop_type_add('MatchType', #{highlight: 'ListMatchGroup', override: v:true})

let s:propBase = #{bufnr: s:buffer, type: 'MatchType'}

command! -nargs=0 ListResume call ListMenuResume(s:menuId)

function! s:listFormat(first, second) abort
    return a:first .. ' ' .. a:second
endfunction

function! s:listTitle(query) abort
    return ' ' .. a:query.title .. ' > ' .. a:query.keyword .. ' '
endfunction

function! s:refreshLine(query, line, filename) abort
    call prop_clear(a:line, a:line, s:propBase)

    let l:data = s:lookup[a:line]
    let l:first = a:filename ? strpart(l:data.path.text, strridx(l:data.path.text, '/') + 1) : l:data.path.text

    call setbufline(s:buffer, a:line, s:listFormat(l:first, l:data.lines.text))
    call prop_add_list(s:propBase, mapnew(l:data.submatches, {_, v -> [a:line, a:query.columnFn(l:first, v.start + 1), a:line, a:query.columnFn(l:first, v.end + 1)]}))
endfunction

function! OnListKey(query, key, line) abort
    if a:key is# '/'
        call DoAsInputOpen(s:dialogId, #{
                    \ titile: s:listTitle(a:query),
                    \ onType: function('OnDialogKey', [a:query]),
                    \ buffer: a:query.keyword
                    \ })
    elseif a:line < len(s:lookup)
        let l:data = s:lookup[a:line]
        if a:key is# "\<cr>"
            execute 'silent! edit ' .. l:data.path.text
            if l:data.line_number > 0
                silent! call cursor(l:data.line_number, l:data.submatches[0].start)
            endif
        elseif a:key is# "\<right>"
            call s:refreshLine(a:query, a:line, v:true)
        elseif a:key is# "\<left>"
            call s:refreshLine(a:query, a:line, v:false)
        endif
    endif
endfunction

function! OnAsyncListData(query, messages) abort
    let l:lines = []
    let l:props = []
    let l:count = len(s:lookup)
    let l:appendLine = l:count - 1

    for message in a:messages
        let json = json_decode(message)
        "{
        "type":"match",
        "data":{
            "path":{
                "text":"markets/internal/src/test/scala/com/folio/dealing/market/internal/replay/OrderBooksLogReplayEndToEndTest.scala"
            "},
            "lines":{
                "text":"      val msgProcessor2 = new RawFixToOrderBookMessageProcessor(testStoreReader, replayedBooks2)\n"
            "},
            "line_number":152,
            "absolute_offset":6108,
            "submatches":[{"match":{"text":"Reader"},"start":73,"end":79}]
        "}
        "}
        if json.type == 'match'
            let l:data = a:query.onDataFn(json.data)
            call add(l:lines, s:listFormat(l:data.path.text, l:data.lines.text))
            call extend(l:props, mapnew(l:data.submatches, {_, v -> [l:count, a:query.columnFn(l:data.path.text, v.start + 1), l:count, a:query.columnFn(l:data.path.text, v.end + 1)]}))
            let l:count += 1

            call add(s:lookup, l:data)
        elseif json.type == 'summary'
            call AsyncJobStop(s:jobId)
        endif
    endfor

    call appendbufline(s:buffer, l:appendLine, l:lines)
    call prop_add_list(s:propBase, l:props)
endfunction

function! OnDialogKey(query, key, message) abort
    if a:key is# "\<cr>" && a:message != a:query.keyword
        let a:query.keyword = a:message
        call s:listAsyncCall(a:query)
    endif
endfunction

"function! s:listAsyncCall(keyword, title = s:title, sink = s:currentCommand, onDataFn = s:onDataFn, columnFn = s:columnFn) abort
function! s:listAsyncCall(query)
    call BufferClear(s:buffer)
    call prop_clear(1, len(s:lookup), s:propBase)
    let s:lookup = [{}]

    if len(a:query.keyword)
        call AsyncJobRun(s:jobId, #{
                    \ cmd: add(['/bin/sh', '-c'], (has_key(a:query, 'sink') ? a:query.sink .. ' | ' : '') .. 'rg --smart-case --json -- ' .. shellescape(a:query.keyword)),
                    \ onData: function('OnAsyncListData', [a:query]),
                    \ })
    else
        call DoAsInputOpen(s:dialogId, #{
                    \ title: s:listTitle(a:query),
                    \ onType: function('OnDialogKey', [a:query]),
                    \ })
    endif

    call ListMenuOpen(s:menuId, #{
                \ title: s:listTitle(a:query),
                \ onKey: function('OnListKey', [a:query]),
                \ })
endfunction

""" Grep
command! -nargs=? ListGrep call s:listAsyncCall(#{
    \ keyword: <q-args>,
    \ title: 'grep',
    \ onDataFn: {data -> data},
    \ columnFn: {path, col -> len(path) + 1 + col},
    \ })

function! s:onFilteredData(data) abort
    let a:data.line_number = -1
    let a:data.path.text = a:data.lines.text
    let a:data.lines.text = ''

    return a:data
endfunction

""" Find
command! -nargs=? ListFind call s:listAsyncCall(#{
            \ keyword: <q-args>,
            \ title: 'find',
            \ sink: (exists("*fugitive#head") && len(fugitive#head())) ? 'find . -type f -print' : 'git ls-files',
            \ onDataFn: function('s:onFilteredData'),
            \ columnFn: {_, col -> col},
            \ })

""" Buffer
function! s:bufferData()
    let l:data = ''
    for info in getbufinfo(#{buflisted: v:true})
        let l:name = (info.name == '' ? '[NO NAME]' : info.name)
        let l:changed = info.changed ? '*' : ''
        let l:data ..= l:name .. '\n'
    endfor

    return l:data
endfunction
command! -nargs=? ListBuffer call s:listAsyncCall(#{
            \ keyword: <q-args>,
            \ title: 'buffer',
            \ sink: 'echo ' .. shellescape(s:bufferData()),
            \ onDataFn: function('s:onFilteredData'),
            \ columnFn: {_, col -> col},
            \ })

""" Test
"command! -nargs=? ListTest call s:listAsyncCall(#{
"            \ keyword: <q-args>,
"            \ title: 'test50',
"            \ sink: "printf \'%s\n\' {1..50}",
"            \ onDataFn: function('s:onFilteredData'),
"            \ columnFn: {_, col -> col},
"            \ })

