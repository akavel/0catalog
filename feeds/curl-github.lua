local json = require 'json'

local function die(msg, ...)
    io.stderr:write(("error: " .. msg .. "\n"):format(...))
    os.exit(1)
end
local function check(test, failmsg, ...)
    if not test then die(failmsg, ...) end
end
-- local function log(...)
--     io.stderr:write(table.concat({...}, '\t') .. '\n')
-- end

local function curl(...)
    local pipe = assert(io.popen(table.concat({"curl", ...}, " ")))
    local output = pipe:read '*a'
    pipe:close()
    --io.stderr:write('RAW: ' .. output .. '\n')
    return output
end

local function main()
    check(#arg == 1, 'expected 1 arg: "username/repo", got %d', #arg)
    local author, repo = arg[1]:match('^([a-zA-Z0-9_%.-]+)/([a-zA-Z0-9_%.-]+)$')
    check(author, 'expected 1 arg: "username/repo", got %q', arg[1])

    -- curl repo description
    local info = json.decode(curl(('https://api.github.com/repos/%s/%s'):format(author, repo)))
    local summary = info.description or ''
    local branch = info.default_branch
    local license = info.license and info.license.spdx_id
    --print(author, repo, branch, summary)

    -- curl newest commit ID
    local info = json.decode(curl(('https://api.github.com/repos/%s/%s/branches/%s'):format(author, repo, branch)))
    local commit = info.commit.sha
    local isodate = info.commit.commit.author.date
    --print(commit, isodate)

    print(('    {%q, %q, %q, %q}, -- license: %q'):format(author .. '/' .. repo, commit, isodate, summary, license))
end

main()

