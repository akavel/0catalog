local list = {
    {"tpope/vim-surround", "f51a26d3710629d031806305b6c8727189cd1935", "2019-11-28T06:29:20Z", "surround.vim: quoting/parenthesizing made simple"},
}

local template = [[
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="feed.xsl"?>
<interface uri="https://raw.githubusercontent.com/akavel/0catalog/master/feeds/{NAME}.xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://zero-install.sourceforge.net/2004/injector/interface http://0install.de/schema/injector/interface/interface.xsd http://0install.de/schema/desktop-integration/capabilities http://0install.de/schema/desktop-integration/capabilities/capabilities.xsd" xmlns="http://zero-install.sourceforge.net/2004/injector/interface">
  <name>{NAME}</name>
  <summary xml:lang="en">{SUMMARY}</summary>
  <homepage>https://github.com/{AUTHOR}/{REPO}</homepage>
  <group>
    <environment name="VIMRUNTIME" insert="" mode="append" />
    <implementation version="{version}">
      <archive href="https://github.com/{AUTHOR}/{REPO}/archive/{commit}.tar.gz"/>
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
    local n, t = select('#', ...), {}
    for i = 1, n do t[i] = tostring(select(i, ...)) end
    io.stderr:write(table.concat(t, '\t') .. '\n')
end
local function mustexec(template, ...)
    assert(os.execute(template:format(...)))
end

local function mkfeed(info)
    local author, repo = info.repo:match('^([a-zA-Z0-9_%.-]+)/([a-zA-Z0-9_%.-]+)$')
    local summary = info.summary or die('summary must not be empty, 0publish will complain, for: %s', info.repo)
    local commit = info.commit
    local isodate = info.isodate

    -- curl commit date -> convert to version 0.YYYYMMDD.hhmmss
    local datepattern = ('(dddd)-(dd)-(dd)T(dd):(dd):(dd)'):gsub('d', '[0-9]')
    local version = ('0.%s%s%s.%s%s%s'):format(isodate:match(datepattern))
    log(version)

    -- replace appropriate fields in template
    local name = (repo:find '^vim-') and repo or ('vim-' .. repo:gsub('%.vim$', ''))
    local fh = assert(io.open('_tmp.xml.template', 'w'))
    fh:write((template:gsub('{([A-Z]+)}', {
        NAME = name,
        AUTHOR = author,
        REPO = repo,
        SUMMARY = summary,
    })))
    fh:close()

    -- make 0install fetch the archive and fill SHA sum
    -- TODO: is there a simpler way to get the SHA sum, size, etc. than by using 0template?
    mustexec('0install run http://0install.net/tools/0template.xml _tmp.xml.template version=%s commit=%s', version, commit)
    os.remove(name .. '.xml')
    mustexec('ren _tmp-%s.xml %s.xml', version, name)
    os.remove('_tmp.xml.template')
    -- TODO: how to automatically sign the resulting feed with my signature???
end

local function main()
    for i, v in ipairs(list) do
        mkfeed{ repo=v[1], commit=v[2], isodate=v[3], summary=v[4] }
    end
end

main()

