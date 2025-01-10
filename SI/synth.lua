local drawer = peripheral.find("storagedrawers:controller")
local itemVault = peripheral.find("create_connected:item_silo") or peripheral.find("create:item_vault")
local inputOutput = peripheral.find("inventory", function (name, _)
    return name ~= peripheral.getName(drawer) and name ~= peripheral.getName(itemVault)
end)

if not drawer or not itemVault or not inputOutput then
    return {}
end

local itemKnowledgeFile = fs.open("SI/itemKnowledge.json", "w")
local currentKnowledge = {}

local function cycleInventory(inventory)
    local list = inventory.list()
    for slot, _ in ipairs(list) do
        local detail = inventory.getItemDetail(slot)
        if currentKnowledge[detail.name] then
            currentKnowledge[detail.name].count = currentKnowledge[detail.name].count + detail.count
            if not currentKnowledge[detail.name].slotMap[peripheral.getName(inventory)] then
                currentKnowledge[detail.name].slotMap[peripheral.getName(inventory)] = {
                    count = detail.count,
                    slot = {slot}
                }
            else
                currentKnowledge[detail.name].slotMap[peripheral.getName(inventory)].count = detail.count + currentKnowledge[detail.name].slotMap[peripheral.getName(inventory)].count
                table.insert(currentKnowledge[detail.name].slotMap[peripheral.getName(inventory)].slot, slot)
            end
        else
            currentKnowledge[detail.name] = {
                displayName = detail.displayName,
                count = detail.count,
                slotMap = {
                    [peripheral.getName(inventory)] = {
                        count = detail.count,
                        slot = {slot}
                    }
                }
            }
        end
    end
end

cycleInventory(drawer)
cycleInventory(itemVault)

itemKnowledgeFile.write(textutils.serialiseJSON(currentKnowledge))