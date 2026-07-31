vim9script

import "./queryType.vim" as qt

export class PathQuery extends qt.QueryType
    var currentPath: string

    def _FormatMode(line: number): dict<any>
        var data = this.lookup[line]
        var indent = repeat('  ', get(data, 'depth', 0))
        if data.isdir
            var symbol = get(data, 'expanded', v:false) ? '- ' : '+ '
            var name = indent .. symbol .. data.name .. '/'
            return {
                text: name,
                props: [
                    { type: 'DirectoryStyle', location: [[line, 1, line, len(name)]] },
                ],
            }
        else
            var name = indent .. '  ' .. data.name
            return {
                text: name,
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
        return ' path: ' .. this.currentPath .. ' [a:add/r:rename/d:delete/c:current] '
    enddef

    def HasCustomKey(key: string): bool
        return ["\<left>", "\<right>", 'h', 'l']->index(key) >= 0
    enddef

    def Start(query: dict<any>): bool
        var keyword = query->get('keyword', '')
        var keep_path = query->get('keepPath', v:false)
        var active_file = expand('%:p')

        if !keep_path || empty(this.currentPath)
            this.currentPath = getcwd()
        endif
        var entries = readdir(this.currentPath)

        this.lookup = [{}] # 1-based index dummy

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
                    path: fullpath,
                    depth: 0,
                    expanded: v:false,
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

        # Automatically expand ancestors of active buffer file and position cursor on it
        if !keep_path && len(keyword) == 0 && !empty(active_file) && filereadable(active_file) && !isdirectory(active_file)
            var root = parentPath
            if active_file[0 : len(root) - 1] ==# root
                var rel_path = active_file[len(root) :]
                var parts = split(rel_path, '/')
                var accum = root[0 : len(root) - 2]

                for i in range(0, len(parts) - 1)
                    accum ..= '/' .. parts[i]
                    var found_line = -1
                    for idx in range(1, len(this.lookup) - 1)
                        if get(this.lookup[idx], 'path', '') ==# accum
                            found_line = idx
                            break
                        endif
                    endfor

                    if found_line != -1
                        if i < len(parts) - 1
                            this._ExpandDir(found_line, v:false)
                        else
                            this.cursorLine = found_line
                        endif
                    else
                        break
                    endif
                endfor
            endif
        endif

        this.Refresh()
        return v:true
    enddef

    def _ExpandDir(line: number, refresh: bool = v:true)
        var data = this.lookup[line]
        if !data.isdir || data.expanded
            return
        endif

        data.expanded = v:true

        var entries = readdir(data.path)
        var dirs = []
        var files = []
        var parentPath = data.path
        if parentPath !~# '/$'
            parentPath ..= '/'
        endif

        for entry in entries
            var fullpath = parentPath .. entry
            var isdir = isdirectory(fullpath)
            var item = {
                name: entry,
                isdir: isdir,
                path: fullpath,
                depth: data.depth + 1,
                expanded: v:false,
            }
            if isdir
                dirs->add(item)
            else
                files->add(item)
            endif
        endfor

        var children = []
        children->extend(dirs)
        children->extend(files)

        if !empty(children)
            var head = this.lookup[ : line]
            var tail = this.lookup[line + 1 : ]
            this.lookup = head + children + tail
        endif

        if refresh
            this.Refresh(line)
        endif
    enddef

    def _CollapseDir(line: number)
        var data = this.lookup[line]
        if !data.isdir || !data.expanded
            return
        endif

        data.expanded = v:false

        var end_idx = line + 1
        while end_idx < len(this.lookup) && get(this.lookup[end_idx], 'depth', 0) > data.depth
            end_idx += 1
        endwhile

        if end_idx - 1 >= line + 1
            this.lookup->remove(line + 1, end_idx - 1)
        endif

        this.Refresh(line)
    enddef

    def _ToggleDir(line: number)
        var data = this.lookup[line]
        if !data.isdir
            return
        endif

        if data.expanded
            this._CollapseDir(line)
        else
            this._ExpandDir(line)
        endif
    enddef

    def OnListKey(key: string, line: number): bool
        if key ==# "\<left>" || key ==# 'h'
            if line < len(this.lookup)
                var data = this.lookup[line]
                if !empty(data) && has_key(data, 'isdir')
                    if get(data, 'depth', 0) > 0
                        var target_depth = data.depth - 1
                        var p = line - 1
                        while p >= 1
                            if get(this.lookup[p], 'depth', 0) == target_depth && get(this.lookup[p], 'isdir', v:false)
                                this._CollapseDir(p)
                                this.cursorLine = p
                                return v:false
                            endif
                            p -= 1
                        endwhile
                    elseif data.isdir && get(data, 'expanded', v:false)
                        this._CollapseDir(line)
                        this.cursorLine = line
                        return v:false
                    endif
                endif
            endif

            this.currentPath = fnamemodify(this.currentPath, ':h')
            this.cursorLine = 1
            this.Start({ keyword: '', keepPath: v:true })
            return v:false
        elseif key ==# 'a'
            this.CreateFileOrDir(line)
            return v:false
        elseif key ==# 'c'
            this.currentPath = getcwd()
            this.Start({ keyword: '' })
            return v:false
        endif

        if line < len(this.lookup)
            var data = this.lookup[line]
            if empty(data) || !has_key(data, 'path') | return v:false | endif

            if key ==# "\<right>" || key ==# 'l'
                if data.isdir
                    if !data.expanded
                        this._ExpandDir(line)
                    else
                        if line + 1 < len(this.lookup) && get(this.lookup[line + 1], 'depth', 0) > data.depth
                            this.cursorLine = line + 1
                        endif
                    endif
                endif
                return v:false
            elseif key ==# "\<cr>"
                if data.isdir
                    this._ToggleDir(line)
                    return v:false
                else
                    this.OpenFile(data.path)
                    return v:true
                endif
            elseif key ==# 'r'
                this.RenameFileOrDir(line)
                return v:false
            elseif key ==# 'd'
                this.DeleteFileOrDir(line)
                return v:false
            endif
        endif

        return v:false
    enddef

    def Preview(line: number)
        if line < len(this.lookup)
            var data = this.lookup[line]
            if !empty(data) && has_key(data, 'path') && !get(data, 'isdir', v:false)
                this.PreviewFile(data.path)
            endif
        endif
    enddef

    def CreateFileOrDir(line: number)
        var targetDir = this.currentPath
        if line < len(this.lookup) && !empty(this.lookup[line]) && has_key(this.lookup[line], 'path')
            var data = this.lookup[line]
            if data.isdir
                targetDir = data.path
            else
                targetDir = fnamemodify(data.path, ':h')
            endif
        endif

        var name = input('Create file/dir (append / for dir): ')
        if empty(name) | return | endif

        var fullpath = targetDir
        if fullpath !~# '/$'
            fullpath ..= '/'
        endif
        fullpath ..= name

        if name =~# '/$'
            mkdir(fullpath, 'p')
        else
            writefile([], fullpath)
        endif

        if line < len(this.lookup) && !empty(this.lookup[line]) && this.lookup[line].isdir
            if this.lookup[line].expanded
                this._CollapseDir(line)
                this._ExpandDir(line)
            else
                this._ExpandDir(line)
            endif
        else
            this.Start({ keyword: '' })
        endif
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
        data.name = new_name
        data.path = new_path
        this.Refresh(line)
    enddef

    def DeleteFileOrDir(line: number)
        var data = this.lookup[line]
        if empty(data) || data.name == '..' | return | endif

        if confirm('Delete ' .. data.name .. '?', "&Yes\n&No") == 1
            if data.isdir && data.expanded
                this._CollapseDir(line)
            endif
            delete(data.path, 'rf')
            this.lookup->remove(line)
            this.Refresh(line)
        endif
    enddef
endclass
