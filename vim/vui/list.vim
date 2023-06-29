
source common.vim

function! s:onSelect(line)
endfunction

let s:listProperties = #{
    \ buffer: #{
        \ name: 'listBuffer',
        \ nr: 0
    \ },
    \ popupMenu: #{
        \ cmd: '',
        \ onSelect: function('s:onSelect'),
        \ opt: #{
            \ pos: 'center',
            \ callback: 's:onEnter',
            \ firstline: 1,
            \ filter: 's:onFilter'
          \ },
    \ },
    \ jobOpt: #{
        \ out_io: 'buffer',
        \ out_buf: 0,
        \ pty: 1,
    \ },
  \ }

function! ListInit(properties)
    let s:listProperties.buffer.nr = BufferAllocate(s:listProperties.buffer.name)
    let s:listProperties.jobOpt.out_buf = bufnr(s:listProperties.buffer.name)

    call s:set(a:properties)
endfunction

function! s:showWindow()
    call popup_menu(s:listProperties.buffer.nr, s:listProperties.popupMenu.opt)
endfunction

function! ListRun(cmd = s:listProperties.popupMenu.cmd)
    call BufferClear(s:listProperties.buffer.nr)
    let g:job = job_start(a:cmd, s:listProperties.jobOpt)
endfunction

function! s:onFilter(id, key)
    call popup_filter_menu(a:id, a:key)
    return v:true
endfunction

function! s:onEnter(id, result)
    if a:result > 0
        let s:listProperties.popupMenu.opt.firstline = a:result
        call s:listProperties.popupMenu.onSelect(getbufline(s:listProperties.buffer.nr, a:result)[0])
    endif
endfunction

function! s:set(properties)
    for [l:key, l:value] in items(a:properties)
        if l:key == 'cmd'
            let s:listProperties.popupMenu.cmd = l:value
        elseif l:key == 'onSelect'
            let s:listProperties.popupMenu.onSelect = function(l:value)
        else
            let s:listProperties.popupMenu.opt[l:key]  = l:value
        endif
    endfor
endfunction

function! ListOpen(properties) abort
    let s:listProperties.popupMenu.opt.firstline = 1

    call s:set(a:properties)
    call ListRun()
    call s:showWindow()
endfunction

function! ListResume() abort
    call s:showWindow()
endfunction

