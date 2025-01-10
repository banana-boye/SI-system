local drawer = peripheral.find("storagedrawers:controller")
local itemVault = peripheral.find("create_connected:item_silo") or peripheral.find("create:item_vault")
local inputOutput = peripheral.find("inventory", function (name, _)
    return name ~= peripheral.getName(drawer) and name ~= peripheral.getName(itemVault)
end)

local itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))

for _, selectedName in pairs(selected) do
    -- {"left":{"count":1,"slot":[3]}}
    for inventory, info in pairs(itemKnowledge[selectedName].slotMap) do
        inputOutput.pullItems(inventory, info.slot)
    end
end