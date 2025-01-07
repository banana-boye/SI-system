-- Check if all files exist
local version = "0"

if not fs.exists("SI") then fs.makeDir("SI") end
if http.get("https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/version.txt").readAll() ~= version then
    for _, file in pairs(fs.list("SI")) do
        shell.run("delete SI/"..file)
    end
    shell.run("delete startup")
    shell.run("wget https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/startup.lua startup")
    shell.run("reboot")
end
if not fs.exists("SI/basalt.lua") then shell.run("wget https://basalt.madefor.cc/install.lua release SI/basalt.lua") end
if not fs.exists("SI/main.lua") then shell.run("wget https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/main.lua SI/main.lua") end

-- Run
shell.run("main.lua")