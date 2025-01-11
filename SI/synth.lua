local drawer = peripheral.find("storagedrawers:controller")
local itemVault = peripheral.find("create_connected:item_silo") or peripheral.find("create:item_vault")

if not drawer or not itemVault then
    return
end
local currentKnowledge = {}

local function cycleInventory(inventory)
    local list = inventory.list()
    for slot, _ in pairs(list) do
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

local itemKnowledgeFile = fs.open("SI/itemKnowledge.json", "w")
itemKnowledgeFile.write(textutils.serialiseJSON(currentKnowledge))
itemKnowledgeFile.close()