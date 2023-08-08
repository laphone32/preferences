
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

call prop_type_add('MatchType', #{highlight: 'Underlined', override: v:true})
let s:propBase = #{bufnr: s:buffer, type: 'MatchType'}

command! -nargs=0 ListResume call ListMenuResume(s:menuId)

function! s:refreshLine(query, line, expand) abort
    call prop_clear(a:line, a:line, s:propBase)

    let l:draw = a:query.onDrawFn(a:line, a:query.onPathFn(s:lookup[a:line], a:expand))
    call setbufline(s:buffer, a:line, l:draw.bufline)
    call prop_add_list(s:propBase, l:draw.prop)
endfunction

function! OnListKey(query, key, line) abort
    if a:key is# '/'
        call DoAsInputOpen(s:dialogId, #{
                    \ title: a:query.title,
                    \ onType: function('OnDialogKey', [a:query]),
                    \ buffer: a:query.keyword
                    \ })
    elseif a:line < len(s:lookup)
        if a:key is# "\<cr>"
            let l:data = s:lookup[a:line]
            execute 'silent! edit ' .. a:query.onPathFn(l:data, v:false)
            if a:query.cursorOnMatch
                silent! call cursor(l:data.line_number, l:data.submatches[0].start)
            endif
        elseif a:key is# "\<right>"
            call s:refreshLine(a:query, a:line, v:true)
        elseif a:key is# "\<left>"
            call s:refreshLine(a:query, a:line, v:false)
        endif
    endif
endfunction

function! OnAsyncRgData(query, messages) abort
    let l:count = len(s:lookup)

    for message in a:messages
        let l:json = json_decode(message)
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
        if l:json.type == 'match'
            let l:json.data.lines.text = trim(l:json.data.lines.text, "\r\t\n", 2)

            call add(s:lookup, l:json.data)
            call s:refreshLine(a:query, l:count, v:false)
            let l:count += 1
        elseif l:json.type == 'summary'
            call AsyncJobStop(s:jobId)
        endif
    endfor
endfunction

function! OnDialogKey(query, key, message) abort
    if a:key is# "\<cr>" && a:message != a:query.keyword
        let a:query.keyword = a:message
        call s:listAsyncRgCall(a:query)
    endif
endfunction

function! s:listAsyncRgCall(query)
    call BufferClear(s:buffer)
    call prop_clear(1, len(s:lookup), s:propBase)
    let s:lookup = [{}]

    let a:query.title = ' ' .. a:query.commandName .. ' > ' .. a:query.keyword .. ' '

    if len(a:query.keyword)
        call AsyncJobRun(s:jobId, #{
                    \ cmd: add(['/bin/sh', '-c'], (has_key(a:query, 'sink') ? a:query.sink .. ' | ' : '') .. 'rg --smart-case --json -- ' .. shellescape(a:query.keyword)),
                    \ onData: function('OnAsyncRgData', [a:query]),
                    \ })
    else
        call DoAsInputOpen(s:dialogId, #{
                    \ title: a:query.title,
                    \ onType: function('OnDialogKey', [a:query]),
                    \ })
    endif

    call ListMenuOpen(s:menuId, #{
                \ title: a:query.title,
                \ onKey: function('OnListKey', [a:query]),
                \ })
endfunction

""" Grep
command! -nargs=? ListGrep call s:listAsyncRgCall(#{
    \ keyword: <q-args>,
    \ commandName: 'grep',
    \ cursorOnMatch: v:true,
    \ onPathFn: {data, expand -> expand ? fnamemodify(data.path.text, ':t') : data.path.text},
    \ onDrawFn: {line, path -> #{
        \ bufline: path .. ' ' .. s:lookup[line].lines.text,
        \ prop: mapnew(s:lookup[line].submatches, {_, v -> [line, len(path) + 1 + v.start + 1, line, len(path) + 1 + v.end + 1]}),
      \ }},
    \ })

""" General Rg filter
function! s:listRgFilter(keyword, name, sink) abort
    call s:listAsyncRgCall(#{
                \ keyword: a:keyword,
                \ commandName: a:name,
                \ sink: a:sink,
                \ cursorOnMatch: v:false,
                \ onPathFn: {data, _ -> data.lines.text},
                \ onDrawFn: {line, path -> #{
                    \ bufline: path,
                    \ prop: mapnew(s:lookup[line].submatches, {_, v -> [line, v.start + 1, line, v.end + 1]}),
                  \ }},
                \ })
endfunction

""" Find
command! -nargs=? ListFind call s:listRgFilter(<q-args>, 'find', (exists("*fugitive#head") && len(fugitive#head())) ? 'find . -type f -print' : 'git ls-files')

""" Buffer
function! s:bufferData()
    return reduce(getbufinfo(#{buflisted: v:true}), {data, info -> data .. (len(info.name) ? info.name : '[NO NAME]' ) .. '\n' }, '')
endfunction
command! -nargs=? ListBuffer call s:listRgFilter(<q-args>, 'buffer', 'echo ' .. shellescape(s:bufferData()))

""" Test
command! -nargs=? ListTest call s:listRgFilter(<q-args>, 'test50', "printf \'%s\n\' {1..50}")

