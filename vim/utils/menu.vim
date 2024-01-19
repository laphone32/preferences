
function! s:onFilter(context, id, key) abort
    let l:line = line('$', a:id)
    let l:pos = popup_getpos(a:id)
    let l:firstline = l:pos.firstline
    let l:height = l:pos.core_height

    let l:index = a:context.index
    let [l:cursorRepeat, l:cursorMove] = [0, '']
    let l:opt = {}

    let l:currentMode = a:context.mode.current

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
    elseif a:key is# "\<right>"
        if l:currentMode < len(a:context.mode.list) - 1
            let l:currentMode += 1
        endif
    elseif a:key is# "\<left>"
        if l:currentMode > 0
            let l:currentMode -= 1
        endif
    elseif a:key is# "\<esc>" || a:key is# 'q'
        call s:hide(a:context)
    else
        if a:key is# "\<cr>"
            call s:hide(a:context)
        endif

        call function(a:context.onKey)(a:key, l:index)
    endif

""    echo 'index=' .. l:index .. ' firstline=' .. l:firstline .. ' newFirstline=' .. get(l:opt, 'firstline', '') .. ' cursorRepeat=' .. l:cursorRepeat .. ' height=' .. l:height .. ' line=' .. l:line

    " mode
    if l:currentMode != a:context.mode.current
        let a:context.mode.current = l:currentMode
        call a:context.mode.list[l:currentMode].func(l:index)
    endif

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

    " update indicator
    call popup_settext(a:context.pageId, ' ' .. join([
        \ l:currentMode > 0 ? '<' : '|',
        \ a:context.mode.list[l:currentMode].name,
        \ l:currentMode < len(a:context.mode.list) - 1 ? '>' : '|',
        \ l:index,
        \ '/',
        \ l:line,
      \ ]) .. ' ')

    return v:true
endfunction

let s:listMenus = []

function! MenuInit(buffer, properties) abort
    let l:context = #{
        \ menuId: -1,
        \ pageId: -1,
        \ index: 1,
        \ onKey: get(a:properties, 'onKey', { key, result -> key }),
        \ }

    call s:set(a:properties, #{
        \ filter: function('s:onFilter', [l:context]),
        \ hidden: v:true,
        \ })

    let l:context.menuId = popup_menu(a:buffer, a:properties)
    let l:opts = popup_getoptions(l:context.menuId)
    let l:pos = popup_getpos(l:context.menuId)

    let l:context.pageId = popup_create('0/0', #{
        \ pos: 'topright',
        \ line: l:pos.line,
        \ col: l:pos.col + l:pos.width - 1,
        \ maxheight: 1,
        \ minheight: 1,
        \ zindex: l:opts.zindex + 1,
        \ hidden: v:true,
      \ })

    let l:context.mode = get(a:properties, 'mode', #{
        \ list: [
            \ #{
                \ name: '',
                \ func: {-> v:null},
              \ }
          \ ],
          \ current: 0,
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
        let l:context.index = 1
        let l:context.onKey = get(a:properties, 'onKey', l:context)
        if (has_key(a:properties, 'mode'))
            let l:context.mode = a:properties.mode
        endif
        call l:context.mode.list[l:context.mode.current].func(1)

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

