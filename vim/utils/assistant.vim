vim9script

import "./term.vim" as te

export class Assistant
    var term: te.Term = null_object

    def _GetConfig(): dict<any>
        return get(g:, 'consistent_popup_assistant', {})
    enddef

    def _ResolveCmd(): list<string>
        var cfg = this._GetConfig()
        var Cfg = get(cfg, 'cmd', get(g:, 'Consistent_popup_assistant_cmd', get(g:, 'consistent_popup_assistant_cmd', v:none)))
        var root = getcwd()
        if type(Cfg) == v:t_func
            return Cfg(root)
        elseif type(Cfg) == v:t_list
            return Cfg
        elseif type(Cfg) == v:t_string && !empty(Cfg)
            return [&shell, '-ic', Cfg]
        endif
        return []
    enddef

    def GetTerm(): te.Term
        if this.term == null_object || this.term.buffer <= 0 || !bufexists(this.term.buffer)
            var cmd = this._ResolveCmd()
            if empty(cmd)
                echohl ErrorMsg | echom 'consistent_popup: assistant cmd is not configured' | echohl None
                return null_object
            endif
            var cfg = this._GetConfig()
            var title = get(cfg, 'title', get(g:, 'consistent_popup_assistant_title', 'Assistant'))
            var width = get(cfg, 'width', get(g:, 'consistent_popup_assistant_width', 100))
            var close_cmd = get(cfg, 'close_on_esc', get(g:, 'consistent_popup_assistant_close_on_esc', v:true)) ? 'HideAssistant' : ''
            this.term = te.Term.new(cmd, title, close_cmd, width)
        endif
        return this.term
    enddef

    def Show()
        var t = this.GetTerm()
        if t != null_object
            t.Show()
        endif
    enddef

    def Hide()
        if this.term != null_object
            this.term.Hide()
        endif
    enddef

    def Kill()
        if this.term != null_object
            this.term.Kill()
        endif
    enddef

    def SendVisual()
        # 1. Gather file relative path and type
        var file_path = expand('%:.')
        var file_type = &filetype
        if empty(file_path)
            file_path = '[No Name]'
        endif

        # 2. Get line range of selection
        var start_line = line("'<")
        var end_line = line("'>")

        # 3. Yank selection to register without polluting user clipboard
        var saved_reg = getreg('"')
        var saved_type = getregtype('"')
        normal! gvy
        var text = getreg('"')
        setreg('"', saved_reg, saved_type)

        if empty(text)
            return
        endif

        var is_first_start = (this.term == null_object || this.term.buffer <= 0 || !bufexists(this.term.buffer))

        # 4. Open/Get the assistant popup
        var t = this.GetTerm()
        if t == null_object
            return
        endif
        t.Show()

        # 5. Format prompt with markdown header and code block
        var header = $"Code snippet from `{file_path}` (lines {start_line}-{end_line}):\n"
        var code_block = $"```{file_type}\n{text}\n```\n"
        var prompt = header .. code_block

        # 6. Feed context into terminal
        var cfg = this._GetConfig()
        var delay = get(cfg, 'startup_delay', get(g:, 'consistent_popup_assistant_startup_delay', 3000))
        if is_first_start && delay > 0
            timer_start(delay, (_) => {
                term_sendkeys(t.buffer, prompt)
            })
        else
            term_sendkeys(t.buffer, prompt)
        endif
    enddef
endclass
