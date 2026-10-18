" Smoke test (Vimscript): syntax file loads cleanly and highlights BQ constructs.
" Run: vim -u NONE -N --not-a-term --cmd "set nomore" -c "set rtp+=." -S tests/smoke.vim -c "qa!"
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

for s:group in ['sqlKeyword', 'sqlStatement', 'sqlType', 'sqlFunction', 'sqlString', 'sqlNumber', 'sqlComment', 'sqlOperator', 'sqlParameter']
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

" String literals (BigQuery lexical reference). See tests/smoke.lua for notes.
function! s:Reload(lines) abort
  enew!
  call setline(1, a:lines)
  runtime syntax/sqlbigquery.vim
  " Materialize top-down; synID() alone doesn't reliably sync with
  " `syn sync ccomment`, while highlighting is computed top-down.
  for l:i in range(1, line('$'))
    for l:c in range(1, max([1, len(getline(l:i))]))
      call synID(l:i, l:c, 1)
    endfor
  endfor
endfunction

function! s:StringLike(lnum, col) abort
  let l:g = synIDattr(synID(a:lnum, a:col, 1), 'name')
  return l:g ==# 'Quote' || l:g ==# 'sqlString'
endfunction

function! s:LiteralOk(literal) abort
  let l:line = getline(1)
  let l:col = stridx(l:line, a:literal) + 1
  if l:col <= 0
    return 0
  endif
  for l:i in range(l:col, l:col + len(a:literal) - 1)
    if !s:StringLike(1, l:i)
      return 0
    endif
  endfor
  let l:after = l:col + len(a:literal)
  return l:after > len(l:line) || !s:StringLike(1, l:after)
endfunction

function! s:LastSwallowed() abort
  let l:n = line('$')
  let l:last = getline(l:n)
  if empty(l:last)
    return 0
  endif
  for l:c in range(1, len(l:last))
    if !s:StringLike(l:n, l:c)
      return 0
    endif
  endfor
  return 1
endfunction

let s:cases = [
      \ ['doc example',
      \  ["SELECT r'\\n' /*Only the prev is raw!*/ '\\n' \"b\" \"\"\"c\"d\"e\"\"\" '''f'g'h''' \"1\" \"2\"", 'from t'],
      \  ["r'\\n'", "'\\n'", "\"b\"", "\"\"\"c\"d\"e\"\"\"", "'''f'g'h'''", "\"1\""]],
      \ ['raw regex',
      \  ["SELECT r'f\\(abc,(.*),def\\)' AS x", 'from t'],
      \  ["r'f\\(abc,(.*),def\\)'"]],
      \ ['raw escaped quote',
      \  ["select r'\\'' as x", 'from t'],
      \  ["r'\\''"]],
      \ ['raw double backslash',
      \  ["select r'\\\\' as x", 'from t'],
      \  ["r'\\\\'"]],
      \ ['quoted escaped backslash',
      \  ["select 'a\\\\' as x, \"b\\\\\" as y from t", 'from t'],
      \  ["'a\\\\'", "\"b\\\\\""]],
      \ ['prefix variants',
      \  ["select rb'a' as a, rB'b' as b, br'c' as c, RB'''d''' as d, R\"e\" as e, B'f' as f from t", 'from t'],
      \  ["rb'a'", "rB'b'", "br'c'", "RB'''d'''", "R\"e\"", "B'f'"]],
      \ ]
for s:case in s:cases
  call s:Reload(s:case[1])
  for s:lit in s:case[2]
    call s:Check(s:LiteralOk(s:lit), s:case[0] . ': ' . s:lit)
  endfor
  call s:Check(!s:LastSwallowed(), s:case[0] . ': does not run away')
endfor

call s:Reload(["select r'''", '  \s+', "''', '') as y", 'from t'])
call s:Check(synIDattr(synID(2, 1, 1), 'name') ==# 'sqlString', 'triple-quoted single raw: line 2 is a string')
call s:Check(synIDattr(synID(3, 1, 1), 'name') ==# 'Quote', 'triple-quoted single raw: closes on line 3')

call s:Reload(["select 'unterminated", 'from t'])
call s:Check(!s:LastSwallowed(), 'unterminated quoted string: next line not swallowed')

" Quoted identifiers share the string-literal escape rules.
call s:Reload(['select `a\`b` as x from t', 'from t'])
call s:Check(s:LiteralOk('`a\`b`'), 'quoted identifier: escaped backtick stays one literal')

" Numeric literals: integers are decimal or 0x hex; float forms per the
" lexical reference. Each must highlight wholly as sqlNumber.
call s:Reload(['select 0xABC as x'])
call s:Check(synIDattr(synID(1, 8, 1), 'name') ==# 'sqlNumber', 'hex integer: 0xABC')
call s:Reload(['select .1E4, 58., 4e2, 123.456e-67 from t'])
call s:Check(synIDattr(synID(1, 8, 1), 'name') ==# 'sqlNumber', 'float: .1E4')
call s:Check(synIDattr(synID(1, 14, 1), 'name') ==# 'sqlNumber', 'float: 58.')
call s:Check(synIDattr(synID(1, 19, 1), 'name') ==# 'sqlNumber', 'float: 4e2')
call s:Check(synIDattr(synID(1, 24, 1), 'name') ==# 'sqlNumber', 'float: 123.456e-67')

" Operators and parameters specific to BigQuery.
call s:Reload(["select 'a' || 'b', fn(y => 1) from t"])
call s:HasAt(1, '||', 'sqlOperator')
call s:HasAt(1, '=>', 'sqlOperator')
call s:Reload(['select a & b, a | b, a ^ b, ~a, a << 1, a >> 1 from t'])
call s:HasAt(1, '&', 'sqlOperator')
call s:HasAt(1, '|', 'sqlOperator')
call s:HasAt(1, '^', 'sqlOperator')
call s:HasAt(1, '~', 'sqlOperator')
call s:HasAt(1, '<<', 'sqlOperator')
call s:HasAt(1, '>>', 'sqlOperator')
call s:Reload(['select a', '|> select b'])
call s:HasAt(2, '|>', 'sqlOperator')
call s:Reload(['select @named, ?, @@sysvar from t'])
call s:HasAt(1, '@named', 'sqlParameter')
call s:HasAt(1, '@@sysvar', 'sqlParameter')
call s:HasAt(1, '?', 'sqlParameter')

if s:failures > 0
  echomsg s:failures . ' check(s) failed'
  cquit 1
else
  echomsg 'smoke OK'
endif
