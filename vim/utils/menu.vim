
function! s:onFilter(context, id, key) abort
    let l:cur = getcurpos(a:id)

    if index([
            \ "\<up>", 'k', "\<c-n>",
            \ "\<down>", 'j', "\<c-p>",
            \ "\<pageup>", "\<c-b>",
            \ "\<pagedown>", "\<c-f>",
            \ "\<home>",
            \ "\<end>", 'G',
        \ ], a:key) >= 0
        call win_execute(a:id, 'normal! ' .. a:key)
    else
        if index([
            \ "\<esc>", 'q',
            \ "\<cr>"
          \ ], a:key) >= 0
            call s:hide(a:context)
        endif

        call function(a:context.onKey)(a:key, l:cur[1])
    endif

    redraw

    let l:cur = getcurpos(a:id)
    call popup_settext(a:context.pageId, ' ' .. l:cur[1] .. ' / ' .. line('$', a:id) .. ' ')

    return v:true
endfunction

let s:listMenus = []

function! MenuInit(buffer, properties) abort
    let l:context = #{
        \ menuId: -1,
        \ pageId: -1,
        \ onKey: get(a:properties, 'onKey', { _, result -> v:null }),
        \ }

    call s:set(a:properties, #{
        \ filter: function('s:onFilter', [l:context]),
        \ hidden: v:true,
        \ })

    let l:context.menuId = popup_menu(a:buffer, a:properties)
    let l:opts = popup_getoptions(l:context.menuId)
    let l:pos = popup_getpos(l:context.menuId)

    let l:context.pageId = popup_create(' 0 / 0 ', #{
        \ pos: 'topright',
        \ line: l:pos.line,
        \ col: l:pos.col + l:pos.width - 1,
        \ maxheight: 1,
        \ minheight: 1,
        \ zindex: l:opts.zindex + 1,
        \ hidden: v:true,
      \ })

    let l:id = len(s:listMenus)
    call add(s:listMenus, l:context)

    return l:id
endfunction

function! MenuBuffer(id) abort
    if a:id < len(s:listMenus)
        return winbufnr(s:listMenus[a:id].menuId)
    endif
endfunction

function! s:set(properties, opt = {})
    if has_key(a:properties, 'width')
        let l:width = a:properties.width
        let a:properties.maxwidth = l:width
        let a:properties.minwidth = l:width
    endif

    if has_key(a:properties, 'height')
        let l:height = a:properties.height
        let a:properties.maxheight = l:height
        let a:properties.minheight = l:height
    endif

    call extend(a:properties, a:opt)
endfunction

function! s:show(context) abort
    call popup_show(a:context.menuId)
    call popup_show(a:context.pageId)
endfunction

function! s:hide(context) abort
    call popup_hide(a:context.menuId)
    call popup_hide(a:context.pageId)
endfunction

function! MenuOpen(id, properties) abort
    if a:id < len(s:listMenus)
        let l:context = s:listMenus[a:id]
        let l:context.onKey = get(a:properties, 'onKey', l:context)

        call s:set(a:properties, #{
            \ firstline: 1
          \ })
        call popup_setoptions(l:context.menuId, a:properties)
        call s:show(l:context)
    endif
endfunction

function! MenuResume(id) abort
    if a:id < len(s:listMenus)
        call s:show(s:listMenus[a:id])
    endif
endfunction

