-- Check if all files exist

if https.get() then end
if not fs.exist("basalt.lua") then shell.run("wget get https://basalt.madefor.cc/install.lua release basalt.lua") end
if not fs.exist("main.lua") then shell.run("wget get https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/main.lua") end

-- Run
shell.run("main.lua")