vim9script

def g:FromSelected(command: string)
    var saved_unnamed_register = getreg('"')
    var saved_unnamed_type = getregtype('"')
    normal! gvy
    var word = getreg('"')
    word = substitute(word, '\n$', '', '')
    word = substitute(word, '\n', ' ', 'g')
    var word_escaped = escape(word, '\|&~')
    setreg('"', saved_unnamed_register, saved_unnamed_type)
    execute substitute(command, '%s', word_escaped, 'g')
enddef

def g:AddListKeyMappings(call_name: string, normal_command: string, virtual_command: string)
    execute 'nnoremap <Plug>(normal-' .. call_name .. ') :' .. normal_command .. '<cr>'
    execute 'vnoremap <Plug>(virtual-' .. call_name .. ") :<C-u>call FromSelected('" .. virtual_command .. "')<cr>"
enddef

# Generic range matching: finds the range under cursor or closest on the current line
# Each item in `items` is a list of at least 4 numbers: [start_line, start_col, end_line, end_col, ...]
def g:UnderCursorOrClosest(line: number, col: number, items: list<list<number>>): list<number>
    var closest_item: list<number> = []
    var closest_distance = -1

    for range in items
        if len(range) < 4
            continue
        endif

        var start_line: number = range[0]
        var start_col: number = range[1]
        var end_line: number = range[2]
        var end_col: number = range[3]

        # 1. Cursor strictly within character range (including point ranges where start_col == end_col)
        var in_range = (line > start_line || (line == start_line && col >= start_col)) &&
              \ (line < end_line || (line == end_line && (col < end_col || (start_col == end_col && col == start_col))))

        # 2. Line-level fallback: cursor is on the line (e.g. blank lines, full-line markers)
        if !in_range && (line >= start_line && line <= end_line)
            in_range = true
        endif

        if in_range
            var distance = line == start_line ? abs(start_col - col) : 0
            if closest_distance < 0 || distance < closest_distance
                closest_item = range
                closest_distance = distance
            endif
        endif
    endfor

    return closest_item
enddef

