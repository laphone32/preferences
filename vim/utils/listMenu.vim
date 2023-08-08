
function! s:onFilter(context, id, key) abort
    let l:line = line('$', a:id)
    let l:pos = popup_getpos(a:id)
    let l:firstline = l:pos.firstline
    let l:height = l:pos.core_height

    let l:index = a:context.index
    let [l:cursorRepeat, l:cursorMove] = [0, '']
    let l:opt = {}

    function! s:home() closure
        if l:firstline < l:height
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<up>"]
        endif

        let l:opt.firstline = 1
        let l:index = 1
    endfunction

    function! s:end() closure
        if l:line - l:firstline < l:height
            let [l:cursorRepeat, l:cursorMove] = [l:line - l:index, "\<down>"]
        else
            let [l:cursorRepeat, l:cursorMove] = [l:height - 1, "\<down>"]
        endif

        let l:opt.firstline = max([1, l:line - l:height + 1])
        let l:index = l:line
    endfunction

    if a:key is# "\<up>"
        if l:index > 1
            let l:index -= 1
            let [l:cursorRepeat, l:cursorMove] = [1, "\<up>"]
        endif
    elseif a:key is# "\<down>"
        if l:index < l:line
            let l:index += 1
            let [l:cursorRepeat, l:cursorMove] = [1, "\<down>"]
        endif
    elseif a:key is# "\<pageup>" || a:key is# "\<c-b>"
        if l:firstline < l:height
            call s:home()
        else
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<down>"]
            let l:index = max([1, l:index - l:height])
            let l:opt.firstline = max([1, l:firstline - l:height])
        endif
    elseif a:key is# "\<pagedown>" || a:key is# "\<c-f>"
        if l:line - l:firstline < l:height
            call s:end()
        else
            let [l:cursorRepeat, l:cursorMove] = [l:index - l:firstline, "\<down>"]
            let l:index = min([l:index + l:height, l:line])
            let l:opt.firstline = l:firstline + l:height
        endif
    elseif a:key is# "\<home>"
        call s:home()
    elseif a:key is# "\<end>" || a:key is# 'G'
        call s:end()
    elseif a:key is# "\<esc>" || a:key is# 'q'
        call popup_hide(a:id)
    else
        if a:key is# "\<cr>"
            call popup_hide(a:id)
        endif

        call function(a:context.onKey)(a:key, l:index)
    endif

""    echo 'index=' .. l:index .. ' firstline=' .. l:firstline .. ' newFirstline=' .. get(l:opt, 'firstline', '') .. ' cursorRepeat=' .. l:cursorRepeat .. ' height=' .. l:height .. ' line=' .. l:line

    " move page
    if len(l:opt) > 0
        call popup_setoptions(a:id, l:opt)
    endif

    " move cursor
    while l:cursorRepeat > 0
        let l:cursorRepeat -= 1
        call popup_filter_menu(a:id, l:cursorMove)
    endwhile

    let a:context.index = l:index
    redraw

    return v:true
endfunction

let s:listMenus = []

function! ListMenuInit(buffer, properties) abort
    let l:context = #{
        \ id: -1,
        \ index: 1,
        \ onKey: get(a:properties, 'onKey', { key, result -> key }),
        \ }

    call s:set(a:properties, #{
        \ filter: function('s:onFilter', [l:context]),
        \ hidden: v:true,
        \ })

    let l:context.id = popup_menu(a:buffer, a:properties)

    let l:id = len(s:listMenus)
    call add(s:listMenus, l:context)

    return l:id
endfunction

function! ListMenuBuffer(id) abort
    if a:id < len(s:listMenus)
        return winbufnr(s:listMenus[a:id].id)
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

function! ListMenuOpen(id, properties) abort
    if a:id < len(s:listMenus)
        let l:context = s:listMenus[a:id]
        let l:context.index = 1
        let l:context.onKey = get(a:properties, 'onKey', l:context)

        call s:set(a:properties, #{
            \ firstline: 1
          \ })
        call popup_setoptions(l:context.id, a:properties)
        call popup_show(l:context.id)
    endif
endfunction

function! ListMenuResume(id) abort
    if a:id < len(s:listMenus)
        call popup_show(s:listMenus[a:id].id)
    endif
endfunction

