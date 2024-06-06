" Key-mappings for tab switching
map <A-1> 1gt
imap <A-1> <ESC>1gt
map <A-2> 2gt
imap <A-2> <ESC>2gt
map <A-3> 3gt
imap <A-3> <ESC>3gt
map <A-4> 4gt
imap <A-4> <ESC>4gt
map <A-5> 5gt
imap <A-5> <ESC>5gt
map <A-6> 6gt
imap <A-6> <ESC>6gt
map <A-7> 7gt
imap <A-7> <ESC>7gt
map <A-8> 8gt
imap <A-8> <ESC>8gt
map <A-9> 9gt
imap <A-9> <ESC>9gt
map <A-Right> :tabn<CR>
imap <A-Right> <ESC>:tabn<CR>
map <A-Left> :tabp<CR>
imap <A-Left> <ESC>:tabp<CR>

map <F8> :vertical diffsplit
map <F9> :set cursorline!<CR>
map <F10> :set cursorcolumn!<CR>

map <A-F12> :terminal<CR>

nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

let mapleader = '\'

" Do not cover the register for the content operated by `dd' and `x'
noremap dd "9dd
noremap x "9x

" LSP
nmap <silent> gd <Plug>(go-to-definition-call)
nmap <silent> gc <Plug>(go-to-declaration-call)
nmap <silent> gy <Plug>(go-to-type-definition-call)
nmap <silent> gi <Plug>(go-to-implementation-call)
nmap <silent> gr <Plug>(go-to-references-call)
nmap <silent> g[ <Plug>(go-to-diagnostic-prev-call)
nmap <silent> g] <Plug>(go-to-diagnostic-next-call)

nmap <silent> gh <Plug>(go-to-help-call)
nmap <silent> ac <Plug>(auto-code-action-call)
nmap <silent> af <Plug>(auto-fix-call)
nmap <silent> ar <Plug>(auto-rename-call)
nmap <silent> al <Plug>(auto-code-lens-call)
nmap <silent> ai <Plug>(auto-import-call)
nmap <silent> am <Plug>(auto-format-call)

" Search list
nmap <silent> <leader>p <Plug>(normal-find-file-call)
vmap <silent> <leader>p <Plug>(virtual-find-file-call)

nmap <silent> <leader>b <Plug>(normal-find-buffer-call)
vmap <silent> <leader>b <Plug>(virtual-find-buffer-call)

nmap <silent> <leader>f <Plug>(normal-grep-file-call)
vmap <silent> <leader>f <Plug>(virtual-grep-file-call)

nmap <silent> <leader>s <Plug>(normal-find-symbol-call)
vmap <silent> <leader>s <Plug>(virtual-find-symbol-call)

nmap <silent> <leader>d <Plug>(normal-find-diagnostic-call)
nmap <silent> <leader><leader> <Plug>(resume-list-call)

" File manager
nmap <silent> <leader>n <Plug>(file-manager-call)

