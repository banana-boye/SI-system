-- Check if all files exist
local version = "0"

if http.get("https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/version.txt").readAll() ~= version then
    for _, file in pairs(fs.list("./")) do
        shell.run("delete "..file)
    end
    shell.run("wget https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/startup.lua startup")
    shell.run("reboot")
end
if not fs.exist("basalt.lua") then shell.run("wget https://basalt.madefor.cc/install.lua release basalt.lua") end
if not fs.exist("main.lua") then shell.run("wget https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/main.lua") end

-- Run
shell.run("main.lua")