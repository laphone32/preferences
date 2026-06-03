vim9script

# Vim Plug
def g:GitBranchName(): string
    return exists('*FugitiveHead') ? call('FugitiveHead', []) : ''
enddef
