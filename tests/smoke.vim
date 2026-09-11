" Smoke test (Vimscript): syntax file loads cleanly and highlights BQ constructs.
" Run: vim -u NONE -N --not-a-term -c "set rtp+=." -S tests/smoke.vim -c "qa!"
runtime syntax/sqlbigquery.vim

let s:failures = 0
function! s:Check(cond, message) abort
  if a:cond
    echomsg 'PASS ' . a:message
  else
    echomsg 'FAIL ' . a:message
    let s:failures += 1
  endif
endfunction

for s:group in ['sqlKeyword', 'sqlStatement', 'sqlType', 'sqlFunction', 'sqlString', 'sqlNumber', 'sqlComment']
  call s:Check(hlexists(s:group), 'highlight group ' . s:group . ' exists')
endfor

enew
call setline(1, [
      \ 'select * from `proj.ds.t` where x = 1 qualify row_number() over (partition by y) = 1',
      \ '-- a comment',
      \ ])
runtime syntax/sqlbigquery.vim

function! s:Groups(line, col) abort
  let l:names = []
  for l:id in synstack(a:line, a:col)
    call add(l:names, synIDattr(l:id, 'name'))
  endfor
  return l:names
endfunction

function! s:HasAt(line, text, group) abort
  let l:col = stridx(getline(a:line), a:text) + 1
  call s:Check(l:col > 0, a:line . ':' . a:text . ' present')
  if l:col > 0
    call s:Check(index(s:Groups(a:line, l:col), a:group) >= 0,
          \ a:line . ':' . a:text . ' has ' . a:group)
  endif
endfunction

call s:HasAt(1, 'select', 'sqlStatement')
call s:HasAt(1, 'qualify', 'sqlKeyword')
call s:HasAt(1, 'row_number', 'sqlFunction')
call s:HasAt(1, 'proj.ds.t', 'sqlString')
call s:HasAt(2, 'comment', 'sqlComment')

if s:failures > 0
  echomsg s:failures . ' check(s) failed'
  cquit 1
else
  echomsg 'smoke OK'
endif
