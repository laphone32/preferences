vim9script

# ============================================================================
# Shared Constants
# ============================================================================
g:diagnostic_signs = {
    error: '>>',
    warning: '!!',
    information: '->',
    hint: '**',
}

# ============================================================================
# Cross-Plugin Function Interfaces (override with `def!` in plugin_setting/)
# ============================================================================

# Returns the current Git branch name for the active buffer, or '' if unavailable.
def g:GitBranchName(): string
    return ''
enddef

# What LspStatus() reports when there is nothing to show.
const EMPTY_LSP_STATUS = {
    error: 0,
    warning: 0,
    information: 0,
    hint: 0,
    progress: '',
}

# Returns structured LSP status for the active buffer.
def g:LspStatus(): dict<any>
    return copy(EMPTY_LSP_STATUS)
enddef

# ============================================================================
# Cross-Plugin User Event Interfaces
# ============================================================================
var lsp_status_change_pending = false
const LSP_STATUS_THROTTLE_MS = 100

# Last LspStatus() seen per buffer, i.e. what the statusline was last drawn from.
# The value is only compared, never inspected, so adapters stay free to fill the
# status however they like. A buffer not seen yet counts as EMPTY_LSP_STATUS, so
# the noise events plugins emit at startup do not redraw the screen (and wipe the
# intro message).
var lsp_status_seen: dict<dict<any>> = {}

def RememberLspStatus()
    lsp_status_seen[string(bufnr())] = g:LspStatus()
enddef

def ForgetLspStatus(bufnum: string)
    silent! remove(lsp_status_seen, bufnum)
enddef

# True (and records the new status) if the current buffer's status differs from
# what was last seen.
def LspStatusChanged(): bool
    var key = string(bufnr())
    var current = g:LspStatus()
    if get(lsp_status_seen, key, EMPTY_LSP_STATUS) == current
        return false
    endif
    lsp_status_seen[key] = current
    return true
enddef

augroup lspStatusSeenGroup
    autocmd!
    # Switching buffers/windows makes listeners redraw from the live status, so
    # re-sync, otherwise a later change back to the old value would look unchanged.
    autocmd BufEnter,WinEnter * RememberLspStatus()
    autocmd BufWipeout * ForgetLspStatus(expand('<abuf>'))
augroup END

# Emits `User LspStatusChange`, throttled, and only if the status of the current
# buffer really changed. Changes in buffers that are not shown need no event:
# listeners redraw from the live status when the buffer is entered.
def g:EmitLspStatusChange()
    if lsp_status_change_pending || !exists('#User#LspStatusChange')
        return
    endif
    lsp_status_change_pending = true
    timer_start(LSP_STATUS_THROTTLE_MS, (_) => {
        lsp_status_change_pending = false
        if exists('#User#LspStatusChange') && LspStatusChanged()
            doautocmd <nomodeline> User LspStatusChange
        endif
    })
enddef
