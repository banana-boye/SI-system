local drawer = peripheral.find("storagedrawers:controller")
local itemVault = peripheral.find("create_connected:item_silo") or peripheral.find("create:item_vault")
local inputOutput = peripheral.find("inventory", function (name, _)
    return name ~= peripheral.getName(drawer) and name ~= peripheral.getName(itemVault)
end)

local itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))

for peri, data in pairs(itemKnowledge[itemName].slotMap) do
    if amount <= 0 then
        break;
    end
    for _, slot in pairs(data.slot) do
        amount = amount - inputOutput.pullItems(peri, slot, amount)
    end
end