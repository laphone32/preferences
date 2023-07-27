
call LoadConfig('utils/asyncJob.vim')
call LoadConfig('utils/doAsInput.vim')
call LoadConfig('utils/listMenu.vim')

let s:height = winheight(0)
let s:width = winwidth(0)
let s:popupHeight = float2nr(s:height * 0.4)
silent! let s:buffer = BufferAllocate('_listsBuffer_')
let s:keyword = ''
let s:keywordLen = 0
let s:title = ''
let s:lookup = [[]]
let s:currentCommand = ''
let s:onDataFn = ''

let s:menuId = ListMenuInit(s:buffer, #{
    \ pos: 'botleft',
    \ line: s:height,
    \ height: s:popupHeight,
    \ width: s:width,
    \ onKey: 'OnListKey'
  \ })
let s:jobId = AsyncJobInit(#{
    \ threshold: s:popupHeight * 2,
    \ onData: 'OnAsyncListData',
  \ })
let s:dialogId = DoAsInputInit(#{
    \ pos: 'botleft',
    \ line: s:height - s:popupHeight,
    \ width: s:width,
    \ onType: 'OnDialogKey',
    \ zindex: 201,
  \ })

command! -nargs=0 ListResume call ListMenuResume(s:menuId)

function! s:listFormat(first, second) abort
    return a:first . ' ' . a:second
endfunction

function! s:listTitleDictionary() abort
    return #{title: ' ' . s:title . ' > ' . s:keyword . ' '}
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
        elseif a:key is# '/'
            call DoAsInputOpen(s:dialogId, extend(s:listTitleDictionary(), #{buffer: s:keyword}))
        endif
    endif
endfunction

highlight ListMatchGroup ctermfg=green guifg=green
call prop_type_add('MatchType', #{highlight: 'ListMatchGroup', override: v:true})

function! OnAsyncListData(messages) abort
    let l:lines = []
    let l:props = []
    let l:appendLine = len(s:lookup) - 1
    let OnDataFnCall = function(s:onDataFn)

    for message in a:messages
        call OnDataFnCall(message, l:lines, l:props)
    endfor

    call appendbufline(s:buffer, l:appendLine, l:lines)
    call prop_add_list(#{type : 'MatchType', bufnr: s:buffer}, l:props)
endfunction

function! OnDialogKey(key, message) abort
    if a:key is# "\<cr>" && a:message != s:keyword
        call s:listAsyncCall(a:message, s:title, s:currentCommand, s:onDataFn)
    endif
endfunction

function! s:listAsyncCall(keyword, title, command, onDataFn) abort
    call BufferClear(s:buffer)
    let s:lookup = [[]]

    let s:keyword = a:keyword
    let s:keywordLen = len(a:keyword)
    let s:title = a:title
    let s:currentCommand = a:command
    let s:onDataFn = a:onDataFn

    let l:cmd = extendnew(['/bin/sh', '-c'], function(a:command)())
    let l:opt = s:listTitleDictionary()

    if s:keywordLen
        call AsyncJobRun(s:jobId, #{cmd: l:cmd})
    else
        call DoAsInputOpen(s:dialogId, l:opt)
    endif

    call ListMenuOpen(s:menuId, l:opt)
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
command! -nargs=? ListGrep call s:listAsyncCall(<q-args>, 'grep', {-> ['rg --vimgrep --smart-case -- ' . string(s:keyword)]}, 's:onGrepData')

function! s:onFilteredData(message, lines, props) abort
    let l:first = stridx(a:message, ':')
    let l:second = stridx(a:message, ':', l:first + 1)

    let l:col = str2nr(strpart(a:message, l:first + 1, l:second - l:first - 1))
    let l:path = strpart(a:message, l:second + 1)

    let l:count = len(s:lookup)
    call add(a:lines, l:path)
    call add(a:props, [l:count, l:col, l:count, l:col + s:keywordLen])
    call add(s:lookup, [l:path, 1, 1, ''])
endfunction

""" Find
command! -nargs=? ListFind call s:listAsyncCall(<q-args>, 'find', {-> [(exists("*fugitive#head") && len(fugitive#head())) ? 'find . -type f -print' : 'git ls-files' . ' | rg --smart-case --color=never --column ' . string(s:keyword)]}, 's:onFilteredData')

""" Buffer
function! s:bufferData()
    let l:data = ''
    for info in getbufinfo(#{buflisted: v:true})
        let l:name = (info.name == '' ? '[NO NAME]' : info.name)
        let l:changed = info.changed ? '*' : ''
        let l:data .= s:listFormat(l:name, l:changed) . '\n'
    endfor

    return l:data
endfunction
command! -nargs=? ListBuffer call s:listAsyncCall(<q-args>, 'buffer', {-> ['echo "' . s:bufferData() . '" | rg --smart-case --color=never --column ' . string(s:keyword)]}, 's:onFilteredData')
