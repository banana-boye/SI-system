--[[
MIT License

Copyright (c) 2024 Orion

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local expect = require "cc.expect"
local expect, field, range = expect.expect, expect.field, expect.range

local function fracture(str)
    local f = {}
    for i in string.gmatch(str, ".") do
        table.insert( f,i )
    end
    return f
end
local function count(str,char)
    expect(1, str, "string")
    expect(2, char, "string")
    local count = 0
    for i in string.gmatch(str,char) do
        count = count + 1
    end
    return count
end
local function hasAtSub(str, toComp, locationOne, locationTwo)
    if string.sub(str, locationOne, locationTwo) == toComp then
        return true
    else
        return false
    end
end
local function startsWith(str, toStart)
    expect(1, str, "string")
    expect(2, toStart, "string")

    return hasAtSub(str, toStart, 1, string.len(toStart))
end
local function endsWith(str, toStart)
    expect(1, str, "string")
    expect(2, toStart, "string")

    local strLen = string.len(str)

    return hasAtSub(str, toStart, strLen, strLen - string.len(toStart))
end
local function xWithAndRemove(str, toStart, condition)
    if condition(str, toStart) then
        return string.sub(str, string.len(toStart)+1, string.len(str))
    else
        return false
    end
end

local funcs = {
    fracture = fracture,
    startsWith = startsWith,
    startsWithAndRemove = function(str, toStart)
        return xWithAndRemove(str, toStart, startsWith)
    end,
    endsWith = endsWith,
    endsWithAndRemove = function (str, toStart)
        return xWithAndRemove(str, toStart, endsWith)
    end,
    wrap = function(str, end_x)
        expect(1, str, "string")
        expect(2, end_x, "number")

        str = fracture(str)
        local new_str = {}
        local curr = ""
        local c = 0
    
        for index, char in pairs(str) do
            if c == end_x then
                curr = curr..char
                table.insert(new_str, curr)
                curr = ""
                c = 0
            else
                curr = curr..char
            end
            c = c + 1
        end
        table.insert(new_str, curr)
        return new_str
    end,
    height = function(str)
        expect(1, str, "string")
        return count(str, "\n")
    end,
    wordWrap = function (str, end_x)
        expect(1, str, "string")
        expect(2, end_x, "number")

        local words = {}
        for word in string.gmatch(str, "%S+") do
            table.insert(words, word)
        end
        words[1] = words[1] and words[1] or nil

        local new_str = {}
        local curr = ""
        local c = 0

        for _, word in ipairs(words) do
            c = c + string.len(word) + 1
            if c > end_x then
                table.insert(new_str, curr)
                curr = word
                c = string.len(word) + 1
            else
                if curr ~= "" then
                    curr = curr .. " " .. word
                else
                    curr = word
                end
            end
        end

        table.insert(new_str, curr)
        return new_str
    end,
    loadingBar = function(progress, width, fill, empty)
        expect(1, progress, "number")
        range(progress, -1,1)
        expect(2, width, "number")
        expect(3, fill, "string", "nil")
        expect(4, empty, "string", "nil")
        fill = fill and fill or "\127"
        empty = empty and empty or " "
        local loading_bar = ""
        width = width - 2
        for i = 1, width do
            loading_bar = (progress * (width)) >= i and loading_bar..fill or loading_bar..empty
        end
        return "["..loading_bar.."]"
    end,
    count = function(str, char)
        count(str,char)
    end,
    centerX = function(str, width)
        expect(1, str, "string")
        expect(2, width, "number")
        return math.floor((width-#str)/2)
    end,
    split = function(str, sep)
        expect(1, str, "string")
        expect(1, str, "string")
        if sep == nil then
            sep = "%s"
        end
        local t = {}
        for sr in string.gmatch(str, "([^"..sep.."]+)") do
            table.insert(t, sr)
        end
        return t
    end,
    replace = function(str, from, to)
        expect(1, str, "string")
        expect(2, from, "string")
        expect(3, to, "string")
        return str:gsub(from, to)
    end
}
local function add()
    for func_name, func in pairs(funcs) do
        string[func_name] = func
    end
end

return add
