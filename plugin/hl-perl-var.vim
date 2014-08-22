" Vim plugin to highlight variables in Perl.

function! s:hlvar()
    if ( exists( "w:current_match" ) )
        call matchdelete( w:current_match )
        unlet w:current_match
    endif

    let l:old_iskeyword = &iskeyword
    set iskeyword=@,$,%,_,48-57,192-255,@-@,{,[
    let l:word = expand( '<cword>' )
    let &iskeyword = l:old_iskeyword

    if ( -1 == match( l:word, '^[%$@]' ) )
        return
    endif

    let l:match = ''

    " $array[1] @array[1,2]
    if (match( l:word, '^[$@][a-zA-Z0-9_\x7f-\xff]\+[') >= 0)
        let l:word = matchstr( l:word, '[a-zA-Z0-9_\x7f-\xff]\+' )
        let l:match = '@' . l:word . '\>\|[$@]' . l:word . '[\@='

    " $hash{key} @hash{key1,key2}
    elseif (match( l:word, '^[$@%][a-zA-Z0-9_\x7f-\xff]\+{') >= 0)
        let l:word = matchstr( l:word, '[a-zA-Z0-9_\x7f-\xff]\+' )
        let l:match = '%' . l:word . '\>\|[$@]' . l:word . '{\@='

    " @array
    elseif (match( l:word, '^@[a-zA-Z0-9_\x7f-\xff]') >= 0)
        let l:match = l:word . '\>\|' . substitute( l:word, '^@', '[@$]', '') . '[\@='

    " %hash
    elseif (match( l:word, '^%[a-zA-Z0-9_\x7f-\xff]') >= 0)
        let l:match = l:word . '\>\|' . substitute( l:word, '^%', '[@$]', '') . '{\@='
    
    " $scalar
    else
        let l:match = l:word . '\>[^}\]]\@='
    endif

    " do the highlighting
    if (strlen(l:match))
        let w:current_match = matchadd( 'PerlVarHiLight', l:match )
    endif
endfunction

if ( ! exists( "g:hlvarnoauto" ) || g:hlvarnoauto == 1 )
    augroup HighlightVar
        autocmd!
        "au FileType perl :au CursorMoved * call <SID>hlvar()
        "au FileType perl :au CursorMovedI * call <SID>hlvar()
        au FileType perl :au CursorHold * call <SID>hlvar()
        au FileType perl :au CursorHoldI * call <SID>hlvar()
    augroup END

    " only add the highlight group if it doesn't already exist.
    " this way, users can define their own highlighting with their
    " favorite colors by having a "highlight PerlVarHiLight ..." statement
    " in their .vimrc
    if ( ! hlexists( 'PerlVarHiLight' ) )
        highlight PerlVarHiLight ctermbg=black guifg=#ff0000 guibg=#000000 ctermfg=LightRed gui=bold
    endif

    command! HlVar :call <SID>hlvar()
endif

