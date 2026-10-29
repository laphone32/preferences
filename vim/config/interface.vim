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

# Returns structured LSP status for the active buffer.
def g:LspStatus(): dict<any>
    return {
        error: 0,
        warning: 0,
        information: 0,
        hint: 0,
        progress: '',
    }
enddef

# ============================================================================
# Cross-Plugin User Event Interfaces
# ============================================================================
var lsp_status_change_pending = false
const LSP_STATUS_THROTTLE_MS = 100

def g:EmitLspStatusChange()
    if lsp_status_change_pending || !exists('#User#LspStatusChange')
        return
    endif
    lsp_status_change_pending = true
    timer_start(LSP_STATUS_THROTTLE_MS, (_) => {
        lsp_status_change_pending = false
        if exists('#User#LspStatusChange')
            doautocmd <nomodeline> User LspStatusChange
        endif
    })
enddef
