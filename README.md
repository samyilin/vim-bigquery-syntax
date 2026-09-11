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

## Test

Neovim (Lua):

```sh
nvim --headless --noplugin -u NONE --cmd "set rtp+=." -l tests/smoke.lua
```

Vim (Vimscript):

```sh
vim -u NONE -N --not-a-term -c "set rtp+=." -S tests/smoke.vim -c "qa!"
```

## Keyword source

Google does not publish a version number for GoogleSQL — the language is
defined by the reference docs, which change continuously. These lists were
curated from the docs on **2026-09-11**:

- https://cloud.google.com/bigquery/docs/reference/standard-sql/lexical
- https://cloud.google.com/bigquery/docs/reference/standard-sql/data-types
- https://cloud.google.com/bigquery/docs/reference/standard-sql/functions-all

Re-check those pages when BigQuery announces new keywords/functions and
update `syntax/sqlbigquery.vim` by hand. Automated scraping is
deliberately avoided: doc pages mix prose, examples, and dotted names
(e.g. `KEYS.NEW_KEYSET`) that need human judgment to turn into Vim
keywords.

## AI disclaimer

These keyword lists were assembled with AI assistance from the pages
above. They are believed accurate as of the date pulled, but the official
BigQuery docs are authoritative — if highlighting disagrees with the
docs, the docs win. Contributions correcting the lists are welcome.
