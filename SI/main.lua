local basalt = require("basalt")
require("extratools")()
local width, height = term.getSize()
local synthFileFunction = loadfile("SI/synth.lua")
local depositFileFunction = loadfile("SI/deposit.lua")
local halfWidth = width / 2
local main = basalt.createFrame()
local synthing = false
fs.default("SI/itemKnowledge.json", "{}")

local itemKnowledge

local synthThread = main:addThread()
synthThread:start(function()
    if synthing then return end
    synthing = true
    synthFileFunction()
    itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))
    synthing = false
end)
itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))

local mainMenu = {}
local withdrawMenu = {}
local withdrawAmountMenu = {}
local depositMenu = {}
local organizeMenu = {}

local function hideMenu(tab, value)
    for _, item in pairs(tab) do
        if type(item) == "table" and item.hide == nil then
            hideMenu(item, value)
        elseif value then
            item:hide()
        else
            item:show()
        end
    end
end

local function swapMenu(from, to)
    hideMenu(from, true)
    hideMenu(to, false)
end

local function query(search)
    local results = {}
    search = string.lower(search)
    local hasInclusiveKeyWord = string.startsWithAndRemove(search, "has: ") or string.startsWithAndRemove(search, "has:")
    if hasInclusiveKeyWord then
        -- Inclusive search
        for name, itemObject in pairs(itemKnowledge) do
            if string.find(string.lower(itemObject.displayName), hasInclusiveKeyWord) ~= nil then
                itemObject.name = name
                table.insert(results, itemObject)
            end
        end
    else
        -- Closest search
        local scores = {}
        search = string.fracture(search)
        local limit = 100
        for name, itemObject in pairs(itemKnowledge) do
            if limit == 0 then
                break
            end
            local score = 0
            local frac = string.fracture(string.lower(itemObject.displayName))
            for pointer, character in pairs(search) do
                if frac[pointer] == character then
                    score = score + 1
                else
                    score = score - 1
                end
            end
            table.insert(scores,{
                name = name,
                object = itemObject,
                score = score
            })
            limit = limit - 1
        end
        table.sort(scores,function(a,b)
            return a.score > b.score
        end)
        for _, value in ipairs(scores) do
            value.object.name = value.name
            table.insert(results, value.object)
        end
    end
    return results
end

withdrawMenu.selected = {}
withdrawMenu.searchResults = {}
withdrawAmountMenu.amounts = {}
withdrawAmountMenu.buttons = {}

withdrawMenu.scrollBar = main:addScrollbar()
    :setPosition(width, 2)
    :setSize(1, height - 1)
    :onChange(function (self, _, value)
        for i, v in pairs(withdrawMenu.searchResults) do
            local newPos = i - value + 2
            if newPos <= 1 then
                v:hide()
            else
                v:show()
                v:setPosition(1, newPos)
            end
        end
    end)

local function renderItemList(itemList, sizeX, sizeY, menu, clickable, start)
    for _, itemObject in pairs(itemList) do
        local button = main:addButton()
            :setSize(sizeX,sizeY)
            :setPosition(1, start+1)
            :setText(itemObject.displayName.." x"..itemObject.count)
            :setBackground(clickable and (menu.selected[itemObject.name] ~= nil and colors.green or colors.gray) or colors.gray)
        if clickable then
            button:onClick(function(self)
                if menu.selected[itemObject.name] == nil then
                    menu.selected[itemObject.name] = itemObject
                    self:setBackground(colors.green)
                else
                    menu.selected[itemObject.name] = nil
                    self:setBackground(colors.gray)
                end
            end)
            table.insert(menu.searchResults, button)
        else
            local textBox = main:addInput()
                :setInputType("number")
                :setSize(sizeX-2, sizeY)
                :setPosition(sizeX, start+1)
                textBox.objectName = itemObject.name
            table.insert(menu.amounts, textBox)
            table.insert(menu.buttons, button)
        end
        start = start + 1
    end
end

local function search()
    for _, v in pairs(withdrawMenu.searchResults) do
        v:remove()
    end
    withdrawMenu.searchResults = {}
    renderItemList(query(withdrawMenu.searchBar:getValue()), width-1, 1, withdrawMenu, true, 1)
    withdrawMenu.scrollBar:setScrollAmount(#withdrawMenu.searchResults)
end

withdrawMenu.searchBar = main:addInput()
    :setInputType("text")
    :setSize(width-2, 1)
    :onKey(function(_, _, key)
        if key == keys.enter or key == keys.numPadEnter then
            search()
        end
    end)
    :onClick(function(self)
        self:setValue("")
    end)


withdrawMenu.searchConfirm = main:addButton()
    :setPosition(width-1,1)
    :setSize(1,1)
    :setText(">")
    :onClick(search)

withdrawMenu.finish = main:addButton()
    :setPosition(width,1)
    :setSize(1,1)
    :setText("\187")
    :setBackground(colors.green)
    :onClick(function ()
        for _, v in pairs(withdrawMenu.searchResults) do
            v:remove()
        end
        local new = {}
        for _, value in pairs(withdrawMenu.selected) do
            table.insert(new, value)
        end
        withdrawMenu.selected = {}
        withdrawMenu.searchResults = {}
        swapMenu(withdrawMenu, withdrawAmountMenu)
        withdrawMenu.searchResults = {}
        
        renderItemList(new, width-22, 1, withdrawAmountMenu, false, 1)
    end)


local loadingBar = main:addProgressbar()
    :setDirection("right")
    :setSize(width - 3, 3)
    :setBackground(colors.gray)
    :setProgressBar(colors.green)
    :setPosition(2, 10)
    :hide()

withdrawAmountMenu.finish = main:addButton()
    :setSize(width, 1)
    :setText("Withdraw")
    :setBackground(colors.green)
    :onClick(function (self, _, value)
        loadingBar:show()
        local size = #withdrawAmountMenu.amounts
        for i, v in pairs(withdrawAmountMenu.amounts) do
            loadfile("SI/withdraw.lua", "t", {
                itemName = v.objectName,
                amount = tonumber(v:getValue()) or 64,
                peripheral = peripheral, textutils = textutils,
                fs = fs,
                string = string,
                pairs = pairs,
                table = table
            })()
            loadingBar:setProgress(i / size * 100)
        end        
        loadingBar:hide()
        swapMenu(withdrawAmountMenu, mainMenu)
    end)

withdrawAmountMenu.scrollBar = main:addScrollbar()
    :setPosition(width, 2)
    :setSize(1, height - 1)
    :onChange(function (self, _, value)
        for i, v in pairs(withdrawAmountMenu.amounts) do
            local newPos = i - value + 2
            if newPos <= 1 then
                v:hide()
            else
                v:show()
                v:setPosition(width-22, newPos)
            end
        end
        for i, v in pairs(withdrawAmountMenu.buttons) do
            local newPos = i - value + 2
            if newPos <= 1 then
                v:hide()
            else
                v:show()
                v:setPosition(1, newPos)
            end
        end
    end)

depositMenu.areYouSure = main:addLabel()
    :setText("Are you sure?")
    :setForeground(colors.red)
    :setFontSize(2)
    :setPosition(halfWidth - 18, 2)

depositMenu.description = main:addLabel()
    :setText("This will deposit all items in the connected inventory into the system")
    :setSize(40,10)
    :setPosition(25, 6)
    :setTextAlign("center")

depositMenu.yes = main:addButton()
    :setText("Yes")
    :setSize(10,3)
    :setPosition(13,10)
    :setForeground(colors.white)
    :setBackground(colors.green)
    :onClick(function ()
        depositFileFunction()
        swapMenu(depositMenu, mainMenu)
    end)

depositMenu.no = main:addButton()
    :setText("No")
    :setSize(10,3)
    :setPosition(width - 21,10)
    :setForeground(colors.white)
    :setBackground(colors.red)
    :onClick(function ()
        swapMenu(depositMenu, mainMenu)
    end)

organizeMenu.areYouSure = main:addLabel()
    :setText("Are you sure?")
    :setForeground(colors.red)
    :setFontSize(2)
    :setPosition(halfWidth - 18, 2)

organizeMenu.organizing = main:addLabel()
    :setText("Organizing")
    :setForeground(colors.red)
    :setFontSize(2)
    :setPosition(halfWidth - 15, -10)

organizeMenu.description = main:addLabel()
    :setText("This will organize all items to their respective storage parts, and might take a while")
    :setSize(40,10)
    :setPosition(30, 6)
    :setTextAlign("center")

organizeMenu.yes = main:addButton()
    :setText("Yes")
    :setSize(10,3)
    :setPosition(13,10)
    :setForeground(colors.white)
    :setBackground(colors.green)
    :onClick(function ()
        loadingBar:show()
        organizeMenu.yes:hide()
        organizeMenu.no:hide()
        organizeMenu.areYouSure:hide()
        organizeMenu.organizing:setPosition(halfWidth - 15, 2)
        organizeMenu.description:hide()

        local i = 1
        local iKSize = #itemKnowledge

        for name, data in pairs(itemKnowledge) do
            loadfile("SI/organize.lua", "t", {
                name = name,
                slotMap = data.slotMap,
                count = data.count,
                peripheral = peripheral,
                pairs = pairs,
                error = error,
                textutils = textutils
            })()
            loadingBar:setProgress((i - 1) / iKSize * 100)
            i = i + 1
        end

        synthing = true
        synthFileFunction()
        itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))
        synthing = false

        loadingBar:hide()
        swapMenu(organizeMenu, mainMenu)
    end)

organizeMenu.no = main:addButton()
    :setText("No")
    :setSize(10,3)
    :setPosition(width - 21,10)
    :setForeground(colors.white)
    :setBackground(colors.red)
    :onClick(function ()
        swapMenu(organizeMenu, mainMenu)
    end)

hideMenu(withdrawMenu, true)
hideMenu(depositMenu, true)
hideMenu(organizeMenu, true)
hideMenu(withdrawAmountMenu, true)

mainMenu.title = main:addLabel()
    :setText("SI system")
    :setFontSize(2)
    :setPosition(halfWidth - 13, 2)

mainMenu.withdrawButton = main:addButton()
    :setPosition(halfWidth -5, height / 2 + 0.5 - 4)
    :setSize(11, 3)
    :setText("WITHDRAW")
    :onClick(function()
        swapMenu(mainMenu, withdrawMenu)
    end)

mainMenu.depositButton = main:addButton()
    :setPosition(halfWidth -4, height / 2 + 0.5)
    :setSize(9, 3)
    :setText("DEPOSIT")
    :onClick(function ()
        swapMenu(mainMenu, depositMenu)
    end)

mainMenu.organizeButton = main:addButton()
    :setPosition(halfWidth -5, height / 2 + 0.5 + 4)
    :setSize(11, 3)
    :setText("ORGANIZE")
    :onClick(function ()
        swapMenu(mainMenu, organizeMenu)
    end)


basalt.autoUpdate()
