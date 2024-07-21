" Render our new buffer list!
function! FilteredBufferList()
    redir => buffer_list
    silent ls!
    redir END

    let buffer_list = split(buffer_list, "\n")
    let current_buffer = bufnr('')

    for buf in buffer_list
        let cbufnr = str2nr(matchstr(buf, '^\s*\zs\d\+\ze'))
        let bufinfo = getbufinfo(cbufnr)[0]
        let sym = WebDevIconsGetFileTypeSymbol(bufinfo.name)

        if cbufnr == current_buffer
            echohl DiffAdd
            if bufinfo.changed
                echohl WildMenu
            endif
        elseif !bufinfo.listed
            echohl Folded
        else
            echohl Title
            if bufinfo.changed
                echohl Directory
                if bufinfo.hidden
                    echohl DiffChange
                endif
            endif
        endif

        echon sym
        echon buf
        echohl None
        echo ''
    endfor
endfunction

" Adapted from: https://vim.fandom.com/wiki/Easier_buffer_switching
function! BufSelP(pattern)
    if a:pattern ==# 'q'
        return -1
    endif
    let bufcount = bufnr("$")
    let currbufnr = 1
    let nummatches = 0
    let firstmatchingbufnr = 0
    while currbufnr <= bufcount
        if(bufexists(currbufnr))
            let currbufname = bufname(currbufnr)
            if(match(currbufname, a:pattern) > -1)
                echo currbufnr . ": ". bufname(currbufnr)
                let nummatches += 1
                let firstmatchingbufnr = currbufnr
            endif
        endif
        let currbufnr = currbufnr + 1
    endwhile
    if(nummatches == 1)
        execute ":buffer ". firstmatchingbufnr
    elseif(nummatches > 1)
        let desiredbufnr = input("Enter buffer number: ")
        if(strlen(desiredbufnr) != 0)
            execute ":buffer ". desiredbufnr
        endif
    else
        echo "No matching buffers"
    endif
endfunction

function! BufSelInt()
    call FilteredBufferList()
    let selection = input('buffer  ')
    let bnr = str2nr(selection)
    if bnr != 0 || selection == '0'
        execute 'buffer ' . bnr
    else
        let r = BufSelP(selection)
        if r ==# -1
            return
        endif
    endif
endfunction

" Bind functions to commands
command! -nargs=1 Bsp :call BufSelP("<args>")
command! Fls call FilteredBufferList()
command! SelBInt call BufSelInt()
