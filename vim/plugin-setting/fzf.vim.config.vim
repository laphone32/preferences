"""""""""""""""""""""""""""""""""""" FZF
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


command! -bang -nargs=0 Files call fzf#vim#files(getcwd(), fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=? -complete=dir Grep call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case -- ' . shellescape(<q-args>) . ' ' . getcwd(), 1, fzf#vim#with_preview(), <bang>0)


"nnoremap <Plug><normal-find-file-call> :GFiles<CR>
"nnoremap <Plug><normal-find-buffer-call> :Buffers<CR>
"nnoremap <Plug><normal-grep-file-call> :Grep<CR>


