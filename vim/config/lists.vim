
call LoadConfig('utils/asyncJob.vim')
call LoadConfig('utils/listMenu.vim')

let s:height = winheight(0)
let s:buffer = BufferAllocate("_listsBuffer_")

let s:keywordLen = 0
let s:menuId = ListMenuInit(s:buffer,
    \ #{
    \ pos: 'botleft',
    \ line: s:height,
    \ height: float2nr(s:height * 0.4),
    \ width: winwidth(0),
  \ })
let s:jobId = -1
let s:lookup = [[]]

function! OnRgKey(key, line) abort
    let l:data = s:lookup[a:line]
    if a:key is# "\<cr>"
        execute 'silent! edit ' . l:data[0]
        silent! call cursor(l:data[1], l:data[2])
    elseif a:key is# "\<right>"
        let l:filename = strpart(l:data[0], strridx(l:data[0], '/') + 1)
        call setbufline(s:buffer, a:line, l:filename . ' ' . l:data[3])
    elseif a:key is# "\<left>"
        call setbufline(s:buffer, a:line, l:data[0] . ' ' . l:data[3])
    endif
endfunction

highlight MatchGroup ctermfg=green guifg=green
call prop_type_add('MatchType', #{highlight: 'MatchGroup', override: v:true})

function! OnRgData(messages) abort
    for message in a:messages
        let l:first = stridx(message, ':')
        let l:second = stridx(message, ':', l:first + 1)
        let l:third = stridx(message, ':', l:second + 1)

        let l:path = strpart(message, 0, l:first)
        let l:row = str2nr(strpart(message, l:first + 1, l:second - l:first - 1))
        let l:col = str2nr(strpart(message, l:second + 1, l:third - l:second - 1))
        let l:line = strpart(message, l:third + 1)

        let l:count = len(s:lookup)
        call appendbufline(s:buffer, l:count - 1, l:path . ' ' . l:line)
        call prop_add(l:count, l:col + len(l:path) + 1, #{type: 'MatchType', length: s:keywordLen, bufnr: s:buffer})
        call add(s:lookup, [l:path, l:row, l:col, l:line])
    endfor
endfunction

function! RgCall(keyword) abort
    if s:jobId != -1
        call AsyncJobStop(s:jobId)
    endif

    call BufferClear(s:buffer)
    let s:lookup = [[]]
    let s:keywordLen = len(a:keyword)

    let s:jobId = AsyncJobRun(#{cmd: ['/bin/sh', '-c', "rg --vimgrep --smart-case -- " . a:keyword], threshold: float2nr(s:height * 0.8), onData: 'OnRgData'})
    call ListMenuOpen(s:menuId, #{title: 'rg > ' . a:keyword, onKey: 'OnRgKey'})
endfunction

command! -nargs=1 Test call RgCall(<q-args>)
command! -nargs=0 TestResume call ListMenuResume(s:menuId)


