
call LoadConfig('utils/asyncJob.vim')
call LoadConfig('utils/listMenu.vim')

let s:height = winheight(0)
silent! let s:buffer = BufferAllocate('_listsBuffer_')
let s:keywordLen = 0
let s:lookup = [[]]

let s:menuId = ListMenuInit(s:buffer,
    \ #{
    \ pos: 'botleft',
    \ line: s:height,
    \ height: float2nr(s:height * 0.4),
    \ width: winwidth(0),
  \ })
let s:jobId = AsyncJobInit(#{
    \ threshold: float2nr(s:height * 0.8)
  \ })
command! -nargs=0 ListResume call ListMenuResume(s:menuId)

function! s:listFormat(first, second) abort
    return a:first . ' ' . a:second
endfunction

function! OnListKey(key, line) abort
    if a:line < len(s:lookup)
        let l:data = s:lookup[a:line]
        if a:key is# "\<cr>"
            execute 'silent! edit ' . l:data[0]
            silent! call cursor(l:data[1], l:data[2])
        elseif a:key is# "\<right>"
            let l:filename = strpart(l:data[0], strridx(l:data[0], '/') + 1)
            call setbufline(s:buffer, a:line, s:listFormat(l:filename, l:data[3]))
        elseif a:key is# "\<left>"
            call setbufline(s:buffer, a:line, s:listFormat(l:data[0], l:data[3]))
        endif
    endif
endfunction

highlight ListMatchGroup ctermfg=green guifg=green
call prop_type_add('MatchType', #{highlight: 'ListMatchGroup', override: v:true})

function! OnAsyncListData(onData, messages) abort
    let l:lines = []
    let l:props = []
    let l:appendLine = len(s:lookup) - 1
    let OnDataFn = function(a:onData)

    for message in a:messages
        call OnDataFn(message, l:lines, l:props)
    endfor

    call appendbufline(s:buffer, l:appendLine, l:lines)
    call prop_add_list(#{type : 'MatchType', bufnr: s:buffer}, l:props)
endfunction

function! s:listCall(keyword, title, generateList) abort
    call BufferClear(s:buffer)
    let s:lookup = [[]]
    let s:keywordLen = len(a:keyword)

    call function(a:generateList)()

    call ListMenuOpen(s:menuId, #{title: ' ' . a:title . ' > ' . a:keyword . ' ', onKey: 'OnListKey'})
endfunction

function! s:listAsyncCall(keyword, title, command, onDataFn) abort
    call s:listCall(a:keyword, a:title, {-> AsyncJobRun(s:jobId, #{cmd: a:command, onData: function('OnAsyncListData', [a:onDataFn])})})
endfunction

""" Grep
function! s:onGrepData(message, lines, props) abort
    let l:first = stridx(a:message, ':')
    let l:second = stridx(a:message, ':', l:first + 1)
    let l:third = stridx(a:message, ':', l:second + 1)

    let l:path = strpart(a:message, 0, l:first)
    let l:row = str2nr(strpart(a:message, l:first + 1, l:second - l:first - 1))
    let l:col = str2nr(strpart(a:message, l:second + 1, l:third - l:second - 1))
    let l:line = strpart(a:message, l:third + 1)

    let l:count = len(s:lookup)
    let l:propCol = l:col + len(l:path) + 1

    call add(a:lines, s:listFormat(l:path, l:line))
    call add(a:props, [l:count, l:propCol, l:count, l:propCol + s:keywordLen])
    call add(s:lookup, [l:path, l:row, l:col, l:line])
endfunction
command! -nargs=1 ListGrep call s:listAsyncCall(<q-args>, 'grep', ['/bin/sh', '-c', 'rg --vimgrep --smart-case -- ' . <q-args>], 's:onGrepData')

""" Find
function! s:onFindData(message, lines, props) abort
    let l:first = stridx(a:message, ':')
    let l:second = stridx(a:message, ':', l:first + 1)
    let l:third = stridx(a:message, ':', l:second + 1)

    let l:col = str2nr(strpart(a:message, l:second + 1, l:third - l:second - 1))
    let l:path = strpart(a:message, l:third + 1)

    let l:count = len(s:lookup)
    call add(a:lines, l:path)
    call add(a:props, [l:count, l:col, l:count, l:col + s:keywordLen])
    call add(s:lookup, [l:path, 1, 1, ''])
endfunction
command! -nargs=1 ListFind call s:listAsyncCall(<q-args>, 'find', ['/bin/sh', '-c', (exists("*fugitive#head") && len(fugitive#head())) ? 'find . -type f -print' : 'git ls-files' . ' | rg --vimgrep --smart-case ' . <q-args>], 's:onFindData')

""" Buffer
function! s:bufferCall()
    let l:lines = []
    for info in getbufinfo(#{buflisted: v:true})
        let l:name = (info.name == '' ? '[NO NAME]' : info.name)
        let l:changed = info.changed ? '*' : ''
        call add(l:lines, s:listFormat(l:name, l:changed))
        call add(s:lookup, [l:name, '', '', l:changed])
    endfor
    call appendbufline(s:buffer, 0, l:lines)
endfunction
command! -nargs=1 ListBuffer call s:listCall(<q-args>, 'buffer', 's:bufferCall')

