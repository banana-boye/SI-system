require("extratools")()
local itemKnowledge = textutils.unserialiseJSON(fs.readAndClose("SI/itemKnowledge.json"))

print(textutils.pagedPrint(textutils.serialise(itemKnowledge["minecraft:chest"].count)))