"""""""""""""""""""""""""""""""""""""" lightline
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'gitbranch', 'filename' ], [ 'lspStatus' ] ],
      \   'right': [ [ 'lineinfo' ], [ 'fileformat', 'fileencoding', 'filetype' ] ]
      \ },
      \ 'inactive': {
      \   'left': [ [ 'filename' ] ],
      \   'right': [ [ 'lineinfo' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'LightLineGitBranch',
      \   'filename': 'LightLineFilename',
      \   'fileformat': 'LightLineFileformat',
      \   'filetype': 'LightLineFiletype',
      \   'fileencoding': 'LightLineFileencoding',
      \   'mode': 'LightLineMode',
      \   'lineinfo': 'LightLineLineInfo',
      \   'lspStatus': 'LspStatus'
      \ },
      \ 'subseparator': { 'left': '|', 'right': '|' }
      \ }
      
function! LightLineModified()
  return &modified ? ' +' : &modifiable ? '' : ' -'
endfunction

function! LightLineReadonly()
  return &readonly ? '= ' : ''
endfunction

function! FileIsNormal()
  return &filetype !~ 'qf\|help\|list\|nerdtree\|vim-plug'
endfunction

function! LightLineFilename()
  let fname = expand('%:t')
  return !FileIsNormal() ? '' :
        \ LightLineReadonly() .
        \ ('' != fname ? fname : '[No Name]') .
        \ LightLineModified()
endfunction

function! WinWidthIsEnough(...)
  let length = a:0 > 0 ? a:1 : 70
  return winwidth(0) > length
endfunction

function! LightLineGitBranch()
  if FileIsNormal() && WinWidthIsEnough()
    let mark = ''  " edit here for cool mark
    let branch = GitBranchName()
    return strlen(branch) ? mark.branch : ''
  else
    return ''
  endif
endfunction

function! LightLineFileformat()
  return WinWidthIsEnough() ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return WinWidthIsEnough() ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return WinWidthIsEnough() ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return !FileIsNormal() ? expand('%:t') : 
        \ WinWidthIsEnough(60) ? lightline#mode() : ''
endfunction

function! LightLineLineInfo()
  return !FileIsNormal() ? '' : printf("%3d:%-2d", line('.'), col('.'))
endfunction

augroup lightlineGroup
  autocmd!
  autocmd User LspStatusChange call lightline#update()
  autocmd BufRead call lightline#update()
augroup end


