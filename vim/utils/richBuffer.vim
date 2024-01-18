
let s:listBuffer = []

function! RichBufferInit(properties) abort
    silent! let l:buffer = BufferAllocate(get(a:properties, 'name', '_richBuffer_' .. len(s:listBuffer)))
    let l:context = #{
        \ buffer: l:buffer,
        \ prop: #{bufnr: l:buffer},
        \ }

    let l:id = len(s:listBuffer)
    call add(s:listBuffer, l:context)

    return l:id
endfunction

function! RichBuffer(id) abort
    if a:id < len(s:listBuffer)
        return s:listBuffer[a:id].buffer
    endif
endfunction

function! RichBufferClear(id, from, to) abort
    if a:id < len(s:listBuffer)
        let l:context = s:listBuffer[a:id]
        call BufferClear(l:context.buffer)
        call prop_clear(a:from, a:to, l:context.prop)
    endif
endfunction

function! RichBufferRefresh(id, properties) abort
    if a:id < len(s:listBuffer) && a:properties.to >= a:properties.from
        let l:context = s:listBuffer[a:id]
        let l:line = a:properties.from
        call prop_clear(a:properties.from, a:properties.to, l:context.prop)

        while l:line <= a:properties.to
            let l:result = a:properties.f(l:line)
            call setbufline(l:context.buffer, l:line, l:result.bufline)
            for l:prop in l:result.props
                call prop_add_list(#{bufnr: l:context.buffer, type: l:prop.type}, l:prop.location)
            endfor
            let l:line += 1
        endwhile
    endif
endfunction

function! RichBufferRefreshLine(id, line, properties) abort
    call RichBufferRefresh(a:id, #{
        \ from: a:line,
        \ to: a:line,
        \ f: {line -> a:properties}
      \ })
endfunction


