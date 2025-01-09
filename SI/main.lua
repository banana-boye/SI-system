local basalt = require("basalt")
local width, height = term.getSize()
local halfWidth = width / 2

local main = basalt.createFrame()

local mainMenu = {}
local withdrawMenu = {}
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

local testList = {
    {
    displayName = "Wood",
    name = "wood",
    modId = "test",
    amount = 64,
    selected = false
},
    {
        displayName = "Log",
        name = "log",
    modId = "test",
    amount = 32,
    selected = false
},
{
        displayName = "Stone",
        name = "stone",
    modId = "test",
    amount = 1,
    selected = false
}
}

local function query(search)
    local results = {}
    local keyword
        if string.find(itemObject.displayName, "\"has:\"", 1, true) then
            keyword = "has"
        end
    for _, itemObject in pairs(testList) do
        if keyword == "has" then
            if
                string.find(itemObject.displayName, search, 1, true) ~= nil
                or string.find(itemObject.name, search, 1, true) ~= nil
            then
                table.insert(results, itemObject)
            end
        end
    end
    return results
end
function table.has(tab, value)
    for i, v in pairs(tab) do
        if v == value then
            return i
        end
    end
    return 0
end

withdrawMenu.selected = {}
withdrawMenu.searchResults = {}

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

local function search()
    withdrawMenu.searchResults = {}
    for i, itemObject in pairs(query(withdrawMenu.searchBar:getValue())) do
        local button = main:addButton()
            :setSize(width-1,1)
            :setPosition(1, i+1)
            :setText(itemObject.displayName.." x"..itemObject.amount)
            :setBackground(table.has(withdrawMenu.selected, itemObject.name) ~= 0 and colors.green or colors.gray)
            :onClick(function(self)
                withdrawMenu.searchResults[i].selected = not withdrawMenu.searchResults[i].selected
                if withdrawMenu.searchResults[i].selected then
                    self:setBackground(colors.green)
                    table.insert(withdrawMenu.selected, itemObject.name)
                else
                    self:setBackground(colors.gray)
                    withdrawMenu.selected[table.has(withdrawMenu.selected, itemObject.name)] = nil
                end
            end)
            
        table.insert(withdrawMenu.searchResults, button)
    end

    withdrawMenu.scrollBar:setScrollAmount(#withdrawMenu.searchResults)
end

withdrawMenu.searchBar = main:addInput()
    :setInputType("text")
    :setSize(width-2, 1)
    :onKey(function(self, event, key)
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
    :onClick() -- run withdraw file

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