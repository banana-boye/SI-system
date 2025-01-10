local basalt = require("basalt")
require("extratools")()
local width, height = term.getSize()
local synthFileFunction = loadfile("SI/synth.lua")
local halfWidth = width / 2
local main = basalt.createFrame()
fs.default("SI/itemKnowledge.json", "{}")
local itemKnowledge

main:addThread():start(function()
    synthFileFunction()
    itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))
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
        for name, itemObject in pairs(itemKnowledge) do
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
                textBox.object = itemObject
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

withdrawAmountMenu.finish = main:addButton()
    :setSize(width, 1)

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
    :onClick() -- deposit shit

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

organizeMenu.progressBar = main:addProgressbar()
    :setDirection("right")
    :setSize(width - 2, 3)
    :setBackground(colors.lightGray)
    :setProgressBar(colors.green)
    :setPosition(2, 10)

organizeMenu.yes = main:addButton()
    :setText("Yes")
    :setSize(10,3)
    :setPosition(13,10)
    :setForeground(colors.white)
    :setBackground(colors.green)
    :onClick(function ()
        organizeMenu.progressBar:setBackground(colors.gray)
        organizeMenu.yes:hide()
        organizeMenu.no:hide()
        organizeMenu.areYouSure:hide()
        organizeMenu.organizing:setPosition(halfWidth - 15, 2)
        organizeMenu.description:hide()

        --organize
        
        local progressFile = fs.open("progress.json", "r")
        local progress = textutils.unserialiseJSON(progressFile.readAll())
        while progress ~= 100 do
            progress = textutils.unserialiseJSON(progressFile.readAll())
            organizeMenu.progressBar:setProgressBar(progress)
        end
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