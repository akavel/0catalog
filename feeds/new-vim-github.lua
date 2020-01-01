local json = require 'json'

local template = [[
<?xml version="1.0" encoding="utf-8"?>
<interface uri="https://raw.githubusercontent.com/akavel/0catalog/master/feeds/{NAME}.xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://zero-install.sourceforge.net/2004/injector/interface http://0install.de/schema/injector/interface/interface.xsd http://0install.de/schema/desktop-integration/capabilities http://0install.de/schema/desktop-integration/capabilities/capabilities.xsd" xmlns="http://zero-install.sourceforge.net/2004/injector/interface">
  <name>{NAME}</name>
  <summary xml:lang="en">{SUMMARY}</summary>
  <homepage>https://github.com/{AUTHOR}/{NAME}</homepage>
  <group>
    <environment name="VIMRUNTIME" insert="" mode="append" />
    <implementation version="{VERSION}">
      <archive href="https://github.com/{AUTHOR}/{NAME}/archive/{COMMIT}.zip"/>
    </implementation>
  </group>
</interface>
]]

local function die(msg, ...)
    io.stderr:write(("error: " .. msg .. "\n"):format(...))
    os.exit(1)
end
local function check(test, failmsg, ...)
    if not test then die(failmsg, ...) end
end
local function log(...)
    io.stderr:write(table.concat({...}, '\t') .. '\n')
end

local function curl(...)
    local pipe = assert(io.popen(table.concat({"curl", ...}, " ")))
    local output = pipe:read '*a'
    pipe:close()
    return output
end

local function main()
    check(#arg == 1, 'expected 1 arg: "username/repo", got %d', #arg)
    local author, repo = arg[1]:match('^([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)$')
    check(author, 'expected 1 arg: "username/repo", got %q', arg[1])

    -- curl repo description
    local info = curl(('https://api.github.com/repos/%s/%s'):format(author, repo))
    local summary = info:match('"description": "([^"]*)"')
    local branch = info:match('"default_branch": "([^"]*)"')
    local license = info:match('"license": ([^,]+)')
    log(author, repo, branch, summary, ("license:%s"):format(license))

    -- curl newest commit ID
    local info = json.decode(curl(('https://api.github.com/repos/%s/%s/branches/%s'):format(author, repo, branch)))
    local commit = info.commit.sha
    local isodate = info.commit.commit.author.date
    log(commit, isodate)

    -- curl commit date -> convert to version 0.YYYYMMDD.hhmmss
    local datepattern = ('(dddd)-(dd)-(dd)T(dd):(dd):(dd)'):gsub('d', '[0-9]')
    local version = ('0.%s%s%s.%s%s%s'):format(isodate:match(datepattern))
    log(version)

    -- replace appropriate fields in template
    print((template:gsub('{([A-Z]+)}', {
        NAME = repo,
        AUTHOR = author,
        SUMMARY = summary,
        VERSION = version,
        COMMIT = commit,
    })))
end

main()

