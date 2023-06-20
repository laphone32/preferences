"""""""""""""""""""""""""""""""""""" FZF

let g:fzf_layout = {
    \ 'down': '40%'
  \ }

let g:fzf_preview_window = ['hidden,right,40%', 'ctrl-/']

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
let g:fzf_history_dir = '~/.local/share/fzf-history'


augroup fzfGroup
    autocmd!
    autocmd FileType fzf set laststatus=0 noshowmode noruler
    autocmd BufLeave <buffer> set laststatus=2 showmode ruler
augroup end


call AddListKeyMappings('find-file-call', 'Files', 'Files %s')
call AddListKeyMappings('grep-file-call', 'RG', 'RG %s')
call AddListKeyMappings('find-buffer-call', 'Buffers', 'Buffers %s')

