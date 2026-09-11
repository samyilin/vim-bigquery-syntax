# vim-bigquery-syntax

Vim syntax for Google BigQuery (GoogleSQL). Fresh keyword/function/type lists
from BigQuery docs (`lexical`, `data-types`, `functions-all`).

## Use standalone

```vim
autocmd BufRead,BufNewFile *.sql set filetype=sqlbigquery
" or: :set syntax=sqlbigquery
```

## Use with dbtpal.nvim (Jinja handled there)

`syntax/dbt.vim` keeps owning Jinja regions and loads this as its base:

```vim
" in your config (dbt.vim reads this, falls back to stock sql.vim):
let g:dbtpal_sql_base = 'sqlbigquery'
```

With `vim.pack`:

```lua
vim.pack.add({
  { src = 'https://github.com/samyilin/vim-bigquery-syntax' },
  { src = 'https://github.com/samyilin/dbtpal.nvim' },
}, { load = true })
```

Groups used: `sqlStatement sqlKeyword sqlOperator sqlType sqlFunction
sqlString sqlNumber sqlComment` — same names as stock `sql.vim` so
overlays and tests keep working.

## Refresh

Compare against https://cloud.google.com/bigquery/docs/reference/standard-sql/lexical
and `functions-all` when BigQuery adds keywords/functions.
