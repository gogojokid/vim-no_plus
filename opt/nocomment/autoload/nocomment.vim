vim9script

# Char {{{

const COMMENT_CHARS = {
	"c": '\/\/',
	"cpp": '\/\/',
	"lua": '--',
	"python": '#',
	"sh": '#',
	"vim": '#'
}

const BLOCK_COMMENT_CHARS = {
    "c": ['\/\* ', ' \*\/'],
    "cpp": ['\/\* ', ' \*\/']
}
# }}}

# Event {{{

def OnCursorMoved(start: number, end: number): void
    var corsor_pos = getpos('.')
    if corsor_pos[1] < start
        corsor_pos[1] = start
        setpos('.', corsor_pos)
    elseif corsor_pos[1] > end
        corsor_pos[1] = end
        setpos('.', corsor_pos)
    else
        return
    endif
enddef
        
def OnTextChanged(start: number, end: number): void
    var corsor_pos = getpos('.')
    var current_line = getline(corsor_pos[1])
    var comment_char = COMMENT_CHARS[&filetype] .. ' '
    var signr = match(current_line, comment_char .. '.*$', 2)
    var comment = current_line[signr : ]
    comment = escape(comment, '/\' .. (&magic ? '&~' : ''))
    var range = start .. ',' .. end
    execute ':' .. range .. 's/\V' .. comment_char .. '\.\*\$/' .. comment .. '/'
    setpos('.', corsor_pos)
enddef

def CallMultiComments(start: number, end: number): void
    var keys = keys(COMMENT_CHARS)
    autocmd_add([
        {
            replace: true,
            group: 'MultiComments',
            event: 'CursorMovedI',
            pattern: '*',
            cmd: 'call OnCursorMoved(' .. start .. ', ' .. end .. ')'
        }, {
            replace: true,
            group: 'MultiComments',
            event: 'TextChangedI',
            pattern: '*',
            cmd: 'call OnTextChanged(' .. start .. ', ' .. end .. ')'
        }, {
            replace: true, 
            group: 'MultiComments', 
            event: 'InsertLeave', 
            pattern: '*',
            cmd: 'call autocmd_delete([{group: "MultiComments"}])'
        }
    ])
enddef
# }}}

# Inside Function {{{

def ToggleComment(start: number, end: number): void
	if has_key(COMMENT_CHARS, &filetype)
		var comment_char = COMMENT_CHARS[&filetype]
		var lines = getline(start, end)
        if empty(filter(lines, (_, val) => val !~# '^\s*' .. comment_char .. ' '))
            execute ":" .. start .. "," .. end .. "s/^\\s*" .. comment_char .. "\\s\\?//"
        else
            execute ":" .. start .. "," .. end .. "s/^/" .. comment_char .. " /"
        endif
		setpos('.', [0, start, 1, 0])
	else
		echomsg "No comment sign found for filetype."
	endif
enddef

def ToggleEndComment(start: number, end: number): void
    if has_key(COMMENT_CHARS, &filetype)
        var lines = getline(start, end)
        var range = start .. ',' .. end
        var replace = '  ' .. COMMENT_CHARS[&filetype] .. ' '
        if empty(filter(lines, (_, val) => val !~# replace .. '.*$'))
            execute ':' .. range .. 's/' .. replace .. '.*$//'
        else
            execute ':' .. range .. 's/\s*$/' .. replace .. '/e'
            setpos('.', [0, start, virtcol('$'), 0])
            CallMultiComments(start, end)
            startinsert!
        endif
    else
        echomsg "No comment sign found for filetype."
    endif
enddef

def ToggleBlockComment(start: number, end: number): void
    if has_key(BLOCK_COMMENT_CHARS, &filetype)
        var block_char = BLOCK_COMMENT_CHARS[&filetype]
        var line0 = getline(start)
        var line1 = getline(end)
        var match0 = matchstrpos(line0, '^' .. block_char[0])
        var match1 = match(line1, block_char[1] .. '$')
        if match0[1] != -1 && match1 != -1
            line0 = line0[match0[2] : ]
            setline(start, line0)
            line1 = getline(end)
            line1 = substitute(line1, block_char[1] .. '$', '', '')
            setline(end, line1)
        else
            line0 = substitute(line0, '^', block_char[0], '')
            setline(start, line0)
            line1 = getline(end)
            line1 = substitute(line1, '$', block_char[1], '')
            setline(end, line1)
        endif
    else
        echomsg "No block comment sign found for filetype."
    endif
enddef
# }}}

# Export Function {{{

export def ToggleCommentDownV(): void
    var start = line("'<")
    var end = line("'>") + max([v:count, 1])
    ToggleComment(start, end)
enddef

export def ToggleCommentUpV(): void
    var end = line("'>")
    var start = line("'<") - max([v:count, 1])
    ToggleComment(start, end)
enddef

export def ToggleCommentRight(): void
    var start = line('.')
    var end = start + v:count
    ToggleEndComment(start, end)
enddef

export def ToggleCommentRightV(): void
    var start = line("'<")
    var end = line("'>") + v:count
    ToggleEndComment(start, end)
enddef

export def ToggleCommentLeft(): void
    var start = line('.')
    var end = start + v:count
    ToggleBlockComment(start, end)
enddef 

export def ToggleCommentLeftV(): void
    var start = line("'<")
    var end = line("'>") + v:count
    ToggleBlockComment(start, end)
enddef
# }}}
