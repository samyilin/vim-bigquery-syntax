-- Smoke test: syntax file loads cleanly and highlights BQ constructs.
-- Run: nvim --headless --noplugin -u NONE --cmd "set rtp+=." -l tests/smoke.lua
vim.cmd("runtime syntax/sqlbigquery.vim")

local function check(cond, message)
    if not cond then
        io.stderr:write("FAIL " .. message .. "\n")
        os.exit(1)
    end
    print("PASS " .. message)
end

for _, group in ipairs({ "sqlKeyword", "sqlStatement", "sqlType", "sqlFunction", "sqlString", "sqlNumber", "sqlComment" }) do
    check(vim.fn.hlexists(group) == 1, "highlight group " .. group .. " exists")
end

local buf = vim.api.nvim_create_buf(false, true)
vim.api.nvim_set_current_buf(buf)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "select * from `proj.ds.t` where x = 1 qualify row_number() over (partition by y) = 1",
    "-- a comment",
})
vim.cmd("runtime syntax/sqlbigquery.vim")

local function groups(line, col)
    local names = {}
    for _, id in ipairs(vim.fn.synstack(line, col)) do
        names[#names + 1] = vim.fn.synIDattr(id, "name")
    end
    return names
end

local function has_at(line, text, group)
    local col = vim.fn.getline(line):find(text, 1, true)
    assert(col, "missing text: " .. text)
    check(vim.tbl_contains(groups(line, col), group), line .. ":" .. text .. " has " .. group)
end

has_at(1, "select", "sqlStatement")
has_at(1, "qualify", "sqlKeyword")
has_at(1, "row_number", "sqlFunction")
has_at(1, "proj.ds.t", "sqlString")
has_at(2, "comment", "sqlComment")

-- String literals (BigQuery lexical reference). A backslash escapes the next
-- character when locating the closing delimiter in every variant, raw
-- included: a raw string keeps the backslash in its value but still can't end
-- on an odd number of backslashes. Quoted (non-triple) strings can't contain
-- newlines, so exactly one line is involved; only triple-quoted literals span
-- lines. Prefixes are b/B, r/R, and rb/br in any order, case-insensitive.
local function reload(lines)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.cmd("runtime syntax/sqlbigquery.vim")
    -- Materialize top-down; synID() alone doesn't reliably sync with
    -- `syn sync ccomment`, while highlighting is computed top-down.
    for i = 1, vim.fn.line("$") do
        for c = 1, math.max(1, #vim.fn.getline(i)) do
            vim.fn.synID(i, c, 1)
        end
    end
end

local function group_at(line, col)
    return vim.fn.synIDattr(vim.fn.synID(line, col, 1), "name")
end

local function string_like(line, col)
    local g = group_at(line, col)
    return g == "Quote" or g == "sqlString"
end

local function last_line_swallowed(lines)
    local n, text = #lines, lines[#lines]
    if text == "" then return false end
    for c = 1, #text do
        if not string_like(n, c) then return false end
    end
    return true
end

-- The literal must be wholly string-like, and the char after it must not be.
local function literal_ok(lnum, text)
    local line = vim.fn.getline(lnum)
    local s = line:find(text, 1, true)
    if not s then return false end
    for i = s, s + #text - 1 do
        if not string_like(lnum, i) then return false end
    end
    local after = s + #text
    return after > #line or not string_like(lnum, after)
end

local function has_literals(label, lines, literals)
    reload(lines)
    for _, lit in ipairs(literals) do
        check(literal_ok(1, lit), label .. ": " .. lit)
    end
    check(not last_line_swallowed(lines), label .. ": does not run away")
end

-- Chunked-literals example from the lexical reference.
has_literals("doc example", {
    [[SELECT r'\n' /*Only the prev is raw!*/ '\n' "b" """c"d"e""" '''f'g'h''' "1" "2"]],
    "from t",
}, { [[r'\n']], [['\n']], [["b"]], [["""c"d"e"""]], [['''f'g'h''']], [["1"]] })

-- Raw regex example from the lexical reference.
has_literals("raw regex", { [[SELECT r'f\(abc,(.*),def\)' AS x]], "from t" },
    { [[r'f\(abc,(.*),def\)']] })

-- Escaped-quote and escaped-backslash cases that used to swallow the file.
has_literals("raw escaped quote", { [[select r'\'' as x]], "from t" }, { [[r'\'']] })
has_literals("raw double backslash", { [[select r'\\' as x]], "from t" }, { [[r'\\']] })
has_literals("quoted escaped backslash", { [[select 'a\\' as x, "b\\" as y from t]], "from t" },
    { [['a\\']], [["b\\"]] })
has_literals("prefix variants", {
    [[select rb'a' as a, rB'b' as b, br'c' as c, RB'''d''' as d, R"e" as e, B'f' as f from t]],
    "from t",
}, { [[rb'a']], [[rB'b']], [[br'c']], [[RB'''d''']], [[R"e"]], [[B'f']] })

-- Triple-quoted literals span lines.
reload({ [[select r''']], [[  \s+]], [[''', '') as y]], "from t" })
check(group_at(2, 1) == "sqlString", "triple-quoted single raw: line 2 is a string")
check(group_at(3, 1) == "Quote", "triple-quoted single raw: closes on line 3")

-- A lone quote is bounded to its line: quoted strings have no newlines.
reload({ [[select 'unterminated]], "from t" })
check(not last_line_swallowed({ [[select 'unterminated]], "from t" }),
    "unterminated quoted string: next line not swallowed")

print("smoke OK")
