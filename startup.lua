-- Check if all files exist

if not fs.exist("basalt.lua") then shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua") end
if not fs.exist("main.lua") then shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua") end

-- Run
shell.run("main.lua")