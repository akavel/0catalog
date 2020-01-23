local list = {
    -- TODO: handle vim `:helptags` somehow; try using https://docs.0install.net/tools/0compile/developers/ with <compile:dup-src .../>
    {"tpope/vim-sensible", "2d9f34c09f548ed4df213389caa2882bfe56db58", "2019-11-24T20:45:22Z", "sensible.vim: Defaults everyone can agree on"}, -- license: nil
    -- TODO: deoplete-nvim ?
    -- TODO: deoplete-go ?
    {"tpope/vim-repeat", "c947ad2b6a16983724a0153bdf7f66d7a80a32ca", "2019-10-26T22:09:00Z", "repeat.vim: enable repeating supported plugin maps with \".\""}, -- license: nil
    {"terryma/vim-expand-region", "966513543de0ddc2d673b5528a056269e7917276", "2013-08-19T15:50:09Z", "Vim plugin that allows you to visually select increasingly larger regions of text using the same key combination."}, -- license: "MIT"
    {"AndrewRadev/splitjoin.vim", "47b1323d1ad6ef9e8fb7527387cd467cfb39ac01", "2019-12-30T10:25:47Z", "Switch between single-line and multiline forms of code"}, -- license: "MIT"
    {"powerman/vim-plugin-AnsiEsc", "690f820d20b6e3a79ba20499874eb7333aa4ca5c", "2019-04-07T14:52:37Z", "ansi escape sequences concealed, but highlighted as specified (conceal)"}, -- license: nil
    {"vim-scripts/DrawIt", "4e824fc939cec81dc2a8f4d91aaeb6151d1cc140", "2013-11-25T00:00:00Z", "Ascii drawing plugin: lines, ellipses, arrows, fills, and more!"}, -- license: nil
    {"chrisbra/changesPlugin", "6bf2c356875dffc61f27fac24fdcdc2d11f14554", "2019-07-16T15:43:37Z", "A Vim Plugin for indicating changes as colored bars using signs."}, -- license: nil
    {"bkad/CamelCaseMotion", "de439d7c06cffd0839a29045a103fe4b44b15cdc", "2019-12-02T19:15:39Z", "A vim script to provide CamelCase motion through words (fork of inkarkat's camelcasemotion script)"}, -- license: nil
    {"tpope/vim-abolish", "7e4da6e78002344d499af9b6d8d5d6fcd7c92125", "2019-10-04T17:23:56Z", "abolish.vim: easily search for, substitute, and abbreviate multiple variants of a word"}, -- license: nil
    -- TODO: add binary for go-explorer
    {"garyburd/go-explorer", "6a82202d18e3b4a4a06b6c22769ee9511335e6ae", "2016-04-24T18:39:38Z", ""}, -- license: "BSD-2-Clause"
    {"fatih/vim-go", "ae7b7ea6dc7a37d425622ab825a46f946694909c", "2020-01-01T16:23:54Z", "Go development plugin for Vim"}, -- license: "NOASSERTION"
    -- TODO: was it nim.vim, or some other one?
    {"zah/nim.vim", "88f5e708a739fb26be6364ab2fabadf9fffb8d7b", "2019-03-02T13:53:41Z", "Nim language plugin for vim"}, -- license: "MIT"
    -- TODO: ack-vim ?
    {"Shougo/neosnippet.vim", "6cccbd41851f3d8f47c5e225d552a217cede4f3f", "2019-12-28T00:36:57Z", "neo-snippet plugin"}, -- license: "NOASSERTION"
    {"tpope/vim-fugitive", "3bf602b13d86b7aef57fec4a2df29467b61435cb", "2019-12-27T22:19:30Z", "fugitive.vim: A Git wrapper so awesome, it should be illegal"}, -- license: nil
    {"tpope/vim-unimpaired", "08e66532bffed445c949ae0a0501940c000553ed", "2019-08-25T22:09:00Z", "unimpaired.vim: Pairs of handy bracket mappings"}, -- license: nil
    {"tpope/vim-surround", "f51a26d3710629d031806305b6c8727189cd1935", "2019-11-28T06:29:20Z", "surround.vim: quoting/parenthesizing made simple"},
    {"tpope/vim-commentary", "f8238d70f873969fb41bf6a6b07ca63a4c0b82b1", "2019-11-18T02:45:53Z", "commentary.vim: comment stuff out"}, -- license: nil
    {"t9md/vim-choosewin", "f91cdb9be92ce3bb9bccba16e8c659d5e8d7454f", "2019-09-17T09:45:39Z", "Land on window you chose like tmux's 'display-pane'"}, -- license: nil
    {"LnL7/vim-nix", "a3eed01f4de995a51dfdd06287e44fcb231f6adf", "2019-06-03T18:02:28Z", "Vim configuration files for Nix http://nixos.org/nix"}, -- license: "MIT"
    {"tpope/vim-obsession", "c44d3c432243d39469046f4e25d38a690e49c755", "2019-10-23T21:55:49Z", "obsession.vim: continuously updated session files"}, -- license: nil
    {"ziglang/zig.vim", "669d4562d3ce0dba704374f1ccca66e4106b5234", "2020-01-21T20:33:12Z", "Vim configuration for Zig"}, -- license: "MIT"
}

local template = [[
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="feed.xsl"?>
<interface uri="https://akavel.github.io/0catalog/feeds/{NAME}.xml" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://zero-install.sourceforge.net/2004/injector/interface http://0install.de/schema/injector/interface/interface.xsd http://0install.de/schema/desktop-integration/capabilities http://0install.de/schema/desktop-integration/capabilities/capabilities.xsd" xmlns="http://zero-install.sourceforge.net/2004/injector/interface">
  <name>{NAME}</name>
  <summary xml:lang="en">{SUMMARY}</summary>
  <homepage>https://github.com/{AUTHOR}/{REPO}</homepage>
  <group>
    <environment name="VIMPATH" insert="" mode="append" />
    <implementation version="{VERSION}" released="{RELEASED}">
      <archive href="https://github.com/{AUTHOR}/{REPO}/archive/{COMMIT}.tar.gz" extract="{REPO}-{COMMIT}"/>
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
local function exists(fname)
    local fh = io.open(fname, 'r')
    if fh then
        fh:close()
        return true
    else
        return false
    end
end

local function splitrepo(repo)
    local author, repo = repo:match('^([a-zA-Z0-9_%.-]+)/([a-zA-Z0-9_%.-]+)$')
    local name = ('vim-%s'):format(repo:gsub('^vim%-', ''):gsub('%.vim$', ''))
    return author, repo, name
end

local function mkfeed(info)
    local author, repo, name = splitrepo(info.repo)
    local summary = info.summary or die('summary must not be empty, 0publish will complain, for: %s', info.repo)
    local commit = info.commit
    local isodate = info.isodate

    -- curl commit date -> convert to version 0.YYYYMMDD.hhmmss
    local datepattern = ('(dddd)-(dd)-(dd)T(dd):(dd):(dd)'):gsub('d', '[0-9]')
    local version = ('0.%s%s%s.%s%s%s'):format(isodate:match(datepattern))
    log(version)

    -- replace appropriate fields in template
    local fname = name .. '.xml'
    local fh = assert(io.open(fname, 'w'))
    fh:write((template:gsub('{([A-Z]+)}', {
        NAME = name,
        AUTHOR = author,
        REPO = repo,
        SUMMARY = summary,
        VERSION = version,
        COMMIT = commit,
        RELEASED = os.date '%Y-%m-%d',
    })))
    fh:close()

    -- make 0install fetch the archive and fill SHA sum
    mustexec('0install run --command=0publish http://0install.de/feeds/ZeroInstall_Tools.xml --xmlsign --add-missing %s', fname)
end

local function main()
    for i, v in ipairs(list) do
        local _, _, name = splitrepo(v[1])
        if not exists(name .. '.xml') then
            mkfeed{ repo=v[1], commit=v[2], isodate=v[3], summary=v[4] }
        end
    end
end

main()

