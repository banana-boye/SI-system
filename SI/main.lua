local basalt = require("basalt")
local width, height = term.getSize()

local main = basalt.createFrame()

local mainMenu = {}
local withDrawMenu = {}

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
    for _, itemObject in pairs(testList) do
        if itemObject.displayName == search then
            return {itemObject}
        end
    end
    return {}
end
function table.has(tab, value)
    for i, v in pairs(tab) do
        if v == value then
            return i
        end
    end
    return 0
end

withDrawMenu.selected = {}
withDrawMenu.searchResults = {}

local function search()
    withDrawMenu.searchResults = {}
    for i, itemObject in pairs(query(withDrawMenu.searchBar:getValue())) do
        local entry
        local button = main:addButton()
            :setSize(width-1,1)
            :setPosition(1, i+1)
            :setText(itemObject.displayName.." x"..itemObject.amount)
            :setBackground(table.has(withDrawMenu.selected, itemObject.name) ~= 0 and colors.green or colors.gray)
            :onClick(function(self)
                withDrawMenu.searchResults[i].selected = not withDrawMenu.searchResults[i].selected
                if withDrawMenu.searchResults[i].selected then
                    self:setBackground(colors.green)
                    table.insert(withDrawMenu.selected, itemObject.name)
                else
                    self:setBackground(colors.gray)
                    basalt.debug(table.has(withDrawMenu.selected, itemObject.name))
                    table.remove(withDrawMenu.selected, table.has(withDrawMenu.selected, itemObject.name))
                end
            end)
            
        table.insert(withDrawMenu.searchResults, button)
    end
end

withDrawMenu.searchBar = main:addInput()
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

withDrawMenu.searchConfirm = main:addButton()
    :setPosition(width-1,1)
    :setSize(2,1)
    :setText(">")
    :onClick(search)


hideMenu(withDrawMenu, true)

mainMenu.title = main:addLabel()
    :setText("SI system")
    :setFontSize(2)
    :setPosition(width / 2 - 13, 2)

mainMenu.withdrawButton = main:addButton()
    :setPosition(width / 2 -5, height / 2 + 0.5 - 4)
    :setSize(11, 3)
    :setText("WITHDRAW")
    :onClick(function()
        swapMenu(mainMenu, withDrawMenu)
    end)

mainMenu.depositButton = main:addButton()
    :setPosition(width / 2 -4, height / 2 + 0.5)
    :setSize(9, 3)
    :setText("DEPOSIT")

mainMenu.organizeButton = main:addButton()
    :setPosition(width / 2 -5, height / 2 + 0.5 + 4)
    :setSize(11, 3)
    :setText("ORGANIZE")


basalt.autoUpdate()