vim9script

import "../utils/rgQuery.vim" as rq
import "../utils/bufferQuery.vim" as sq
import "../utils/findQuery.vim" as fq
import "../utils/list.vim" as li

var height = winheight(0)
var width = float2nr(winwidth(0))
var popupHeight = float2nr(height * 0.55)

prop_type_add('FileStyle', {highlight: 'Statement', override: v:true})
prop_type_add('MatchStyle', {highlight: 'Underlined', override: v:true})

var list = li.List.new(height, width, popupHeight)
var rg = rq.AsyncRgQuery.new()
var find = fq.AsyncFindQuery.new()
var buffer = sq.BufferQuery.new()

command! -nargs=0 ListResume list.Resume()
command! -nargs=? ListGrep list.Call(rg, {
    \ keyword: <q-args>,
\ })
command! -nargs=? ListFind list.Call(find, {
    \ keyword: <q-args>,
\ })
command! -nargs=? ListBuffer list.Call(buffer, {
    \ keyword: <q-args>,
\ })


### Test
#command! -nargs=? ListTest ListAsyncRgCall({
#    \ keyword: empty(<q-args>) ? '.' : <q-args>,
#    \ commandName: 'test50',
#    \ sink: "printf \'%s\n\' {1..50}",
#    \ cursorOnMatch: v:false,
#    \ onPathFn: (data) => data.lines.text,
#    \ render: [(line) => ({ text: lookup[line].lines.text, }),],
#    \ mode: 0,
#\ })

### keymap
call AddListKeyMappings('find-file-call', 'ListFind', "ListFind %s")
call AddListKeyMappings('grep-file-call', 'ListGrep', 'ListGrep %s')
call AddListKeyMappings('find-buffer-call', 'ListBuffer', 'ListBuffer %s')
nnoremap <Plug>(resume-list-call) :ListResume<cr>

