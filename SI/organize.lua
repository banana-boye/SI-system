local drawer = peripheral.find("storagedrawers:controller")
local itemVault = peripheral.find("create_connected:item_silo") or peripheral.find("create:item_vault")

if count <= 64 then
    for peri, slots in pairs(slotMap) do
        for _, slot in pairs(slots.slot) do
            itemVault.pullItems(peri, slot, count)
        end
    end
else
    for peri, slots in pairs(slotMap) do
        for _, slot in pairs(slots.slot) do
            drawer.pullItems(peri, slot, count)
        end
    end
end