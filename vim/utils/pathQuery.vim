vim9script

import "./queryType.vim" as qt

export class PathQuery extends qt.QueryType
    var currentPath: string

    def _FormatMode(line: number): dict<any>
        var data = this.lookup[line]
        if data.isdir
            var name = data.name .. '/'
            return {
                text: '+ ' .. name,
                props: [
                    { type: 'DirectoryStyle', location: [[line, 1, line, len(name) + 3]] },
                ],
            }
        else
            return {
                text: '  ' .. data.name,
            }
        endif
    enddef

    def new()
        this.name = ' path > '
        this.modes = [
            this._FormatMode,
        ]
        this.currentMode = 0
        this.currentPath = getcwd()
    enddef

    def GetTitle(keyword: string): string
        return ' path: ' .. this.currentPath .. ' [a:add/r:rename/d:delete] '
    enddef

    def HasCustomKey(key: string): bool
        return ["\<left>", "\<right>", 'h', 'l']->index(key) >= 0
    enddef

    def Start(query: dict<any>): bool
        var keyword = query->get('keyword', '')
        var entries = readdir(this.currentPath)

        this.lookup = [{}] # 1-based index dummy


        # 2. Add folders first, then files (both sorted alphabetically by default from readdir)
        var dirs = []
        var files = []
        var parentPath = this.currentPath
        if parentPath !~# '/$'
            parentPath ..= '/'
        endif

        for entry in entries
            var fullpath = parentPath .. entry
            var isdir = isdirectory(fullpath)
            if len(keyword) == 0 || entry =~? keyword
                var item = {
                    name: entry,
                    isdir: isdir,
                    path: fullpath
                }
                if isdir
                    dirs->add(item)
                else
                    files->add(item)
                endif
            endif
        endfor

        this.lookup->extend(dirs)
        this.lookup->extend(files)

        this.Refresh()
        return v:true
    enddef

    def OnListKey(key: string, line: number)
        if key ==# "\<left>" || key ==# 'h'
            this.currentPath = fnamemodify(this.currentPath, ':h')
            this.cursorLine = 1
            this.Start({ keyword: '' })
            return
        elseif key ==# 'a'
            this.CreateFileOrDir()
            return
        endif

        if line < len(this.lookup)
            var data = this.lookup[line]
            if empty(data) || !has_key(data, 'path') | return | endif

            if key ==# "\<right>" || key ==# 'l'
                if data.isdir
                    this.currentPath = data.path
                    this.cursorLine = 1
                    this.Start({ keyword: '' })
                endif
            elseif key ==# "\<cr>"
                this.OpenFile(data.path)
            elseif key ==# 'r'
                this.RenameFileOrDir(line)
            elseif key ==# 'd'
                this.DeleteFileOrDir(line)
            endif
        endif
    enddef

    def Preview(line: number)
        if line < len(this.lookup)
            var data = this.lookup[line]
            if !empty(data) && has_key(data, 'path') && !data.isdir
                this.PreviewFile(data.path)
            endif
        endif
    enddef

    def CreateFileOrDir()
        var name = input('Create file/dir (append / for dir): ')
        if empty(name) | return | endif

        var fullpath = this.currentPath
        if fullpath !~# '/$'
            fullpath ..= '/'
        endif
        fullpath ..= name

        if name =~# '/$'
            mkdir(fullpath, 'p')
        else
            writefile([], fullpath)
        endif
        this.Start({ keyword: '' })
    enddef

    def RenameFileOrDir(line: number)
        var data = this.lookup[line]
        if empty(data) || data.name == '..' | return | endif

        var new_name = input('Rename to: ', data.name)
        if empty(new_name) || new_name == data.name | return | endif

        var parent = fnamemodify(data.path, ':h')
        if parent !~# '/$'
            parent ..= '/'
        endif
        var new_path = parent .. new_name
        rename(data.path, new_path)
        this.Start({ keyword: '' })
    enddef

    def DeleteFileOrDir(line: number)
        var data = this.lookup[line]
        if empty(data) || data.name == '..' | return | endif

        if confirm('Delete ' .. data.name .. '?', "&Yes\n&No") == 1
            delete(data.path, 'rf')
            this.Start({ keyword: '' })
        endif
    enddef
endclass
