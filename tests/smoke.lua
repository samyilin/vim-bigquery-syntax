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
print("smoke OK")
