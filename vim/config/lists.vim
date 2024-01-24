
call LoadConfig('utils/asyncJob.vim')
call LoadConfig('utils/doAsInput.vim')
call LoadConfig('utils/menu.vim')
call LoadConfig('utils/richBuffer.vim')

let s:height = winheight(0)
let s:width = float2nr(winwidth(0))
let s:popupHeight = float2nr(s:height * 0.45)

call prop_type_add('FileStyle', #{highlight: 'Statement', override: v:true})
call prop_type_add('MatchStyle', #{highlight: 'Underlined', override: v:true})

let s:buffer = RichBufferInit(#{
    \ name: '_listsBuffer_',
  \ })
let s:lookup = [{}]

let s:menuId = MenuInit(RichBuffer(s:buffer), #{
    \ pos: 'botleft',
    \ line: s:height,
    \ height: s:popupHeight,
    \ width: s:width,
    \ zindex: 200,
  \ })
let s:jobId = AsyncJobInit(#{
    \ out_mode: 'JSON',
    \ threshold: s:popupHeight * 2,
  \ })
let s:dialogId = DoAsInputInit(#{
    \ pos: 'botleft',
    \ line: s:height - s:popupHeight,
    \ width: s:width,
    \ zindex: 250,
  \ })

command! -nargs=0 ListResume call MenuResume(s:menuId)

function! s:refreshBuffer(query, from, expand) abort
    call RichBufferRefresh(s:buffer, #{
        \ from: a:from,
        \ to: len(s:lookup) - 1,
        \ f: {line -> a:query.onDrawFn(line, a:query.onPathFn(s:lookup[line], a:expand))}
        \ })
endfunction

function! OnListKey(query, key, line) abort
    let l:hideMenu = v:false

    if a:key is# '/'
        call DoAsInputOpen(s:dialogId, #{
                    \ title: a:query.title,
                    \ onType: function('OnDialogKey', [a:query]),
                    \ buffer: a:query.keyword
                    \ })
    elseif a:key is# "\<right>"
        call s:refreshBuffer(a:query, 1, v:true)
    elseif a:key is# "\<left>"
        call s:refreshBuffer(a:query, 1, v:false)
    elseif a:line < len(s:lookup)
        if a:key is# "\<cr>"
            let l:data = s:lookup[a:line]
            execute 'silent! edit ' .. a:query.onPathFn(l:data, v:false)
            if a:query.cursorOnMatch
                silent! call cursor(l:data.line_number, l:data.submatches[0].start)
            endif
            let l:hideMenu = v:true
        endif
    endif

    return l:hideMenu
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
        elseif l:json.type == 'summary'
            call AsyncJobStop(s:jobId)
        endif
    endfor

    call s:refreshBuffer(a:query, l:count, v:true)
endfunction

function! OnDialogKey(query, key, message) abort
    if a:key is# "\<cr>" && a:message !=# a:query.keyword
        let a:query.keyword = a:message
        call s:listAsyncRgCall(a:query)
    endif
endfunction

function! s:listAsyncRgCall(query)
    call RichBufferClear(s:buffer, 1, len(s:lookup))
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

    call MenuOpen(s:menuId, #{
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
        \ props: [
            \ #{
                \ type: 'FileStyle',
                \ location: [[line, 1, line, len(path) + 1]],
              \ },
            \ #{
                \ type: 'MatchStyle',
                \ location: mapnew(s:lookup[line].submatches, {_, v -> [line, len(path) + 1 + v.start + 1, line, len(path) + 1 + v.end + 1]}),
              \ },
          \ ],
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
                    \ props: [
                        \ #{
                            \ type: 'MatchStyle',
                            \ location: mapnew(s:lookup[line].submatches, {_, v -> [line, v.start + 1, line, v.end + 1]}),
                        \ },
                    \ ],
                  \ }},
                \ })
endfunction

""" Find
command! -nargs=? ListFind call s:listAsyncRgCall(#{
    \ keyword: <q-args>,
    \ commandName: 'find',
    \ sink: (exists("*fugitive#head") && len(fugitive#head())) ? 'find . -type f -print' : 'git ls-files',
    \ cursorOnMatch: v:false,
    \ onPathFn: {data, _ -> data.lines.text},
    \ onDrawFn: {line, path -> #{
        \ bufline: path,
        \ props: [
            \ #{
                \ type: 'MatchStyle',
                \ location: mapnew(s:lookup[line].submatches, {_, v -> [line, v.start + 1, line, v.end + 1]}),
            \ },
        \ ],
      \ }},
    \ })

""" Buffer
command! -nargs=? ListBuffer call s:listAsyncRgCall(#{
    \ keyword: empty(<q-args>) ? '.' : <q-args>,
    \ commandName: 'buffer',
    \ sink: 'echo ' .. shellescape(reduce(getbufinfo(#{buflisted: v:true}), {data, info -> data .. (len(info.name) ? info.name : '[NO NAME]' ) .. '\n' }, '')),
    \ cursorOnMatch: v:false,
    \ onPathFn: {data, _ -> data.lines.text},
    \ onDrawFn: {line, path -> #{
        \ bufline: path,
        \ props: [
            \ #{
                \ type: 'MatchStyle',
                \ location: mapnew(s:lookup[line].submatches, {_, v -> [line, v.start + 1, line, v.end + 1]}),
            \ },
        \ ],
      \ }},
    \ })

""" Test
command! -nargs=? ListTest call s:listRgFilter(<q-args>, 'test50', "printf \'%s\n\' {1..50}")

""" keymap
call AddListKeyMappings('find-file-call', 'ListFind', "ListFind %s")
call AddListKeyMappings('grep-file-call', 'ListGrep', 'ListGrep %s')
call AddListKeyMappings('find-buffer-call', 'ListBuffer', 'ListBuffer %s')
nnoremap <Plug>(resume-list-call) :ListResume<cr>

