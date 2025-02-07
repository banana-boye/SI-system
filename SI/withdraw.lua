local drawer = peripheral.find("storagedrawers:controller")
local itemVault = peripheral.find("create_connected:item_silo") or peripheral.find("create:item_vault")
local inputOutput = peripheral.find("inventory", function (name, _)
    return name ~= peripheral.getName(drawer) and name ~= peripheral.getName(itemVault)
end)
local inputSize = inputOutput.size()

local itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))
local current = 0

for peri, data in pairs(itemKnowledge[itemName].slotMap) do
    if current >= amount or current >= inputSize then
        break;
    end
    for _, slot in pairs(data.slot) do
        current = current + inputOutput.pullItems(peri, slot, amount - current)
    end
end

local itemKnowledgeFile = fs.open("SI/itemKnowledge.json", "w")
itemKnowledgeFile.write(textutils.serialiseJSON(itemKnowledge))
itemKnowledgeFile.close()