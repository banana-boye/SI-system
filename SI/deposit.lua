local drawer = peripheral.find("storagedrawers:controller")
local itemVault = peripheral.find("create_connected:item_silo") or peripheral.find("create:item_vault")
local inputOutput = peripheral.find("inventory", function (name, _)
    return name ~= peripheral.getName(drawer) and name ~= peripheral.getName(itemVault)
end)

local itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))

for slot, _ in pairs(inputOutput.list()) do
    inputOutput.pushItems(peripheral.getName(drawer), slot)
end

local itemKnowledgeFile = fs.open("SI/itemKnowledge.json", "w")
itemKnowledgeFile.write(textutils.serialiseJSON(itemKnowledge))
itemKnowledgeFile.close()