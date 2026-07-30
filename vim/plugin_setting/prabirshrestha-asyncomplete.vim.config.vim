vim9script

# asyncomplete

g:asyncomplete_auto_popup = 1

# Disable automatic management so we can use our custom completeopt
g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert,noselect

# Use Tab/S-Tab for completion menu navigation
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"



