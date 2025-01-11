-- Check if all files exist
local version = "1"

if not fs.exists("SI") then fs.makeDir("SI") end
if http.get("https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/version.txt").readAll() ~= version then
    for _, file in pairs(fs.list("SI")) do
        shell.run("delete SI/"..file)
    end
    shell.run("delete startup")
    shell.run("wget https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/startup.lua startup")
    shell.run("reboot")
end
if not fs.exists("SI/basalt.lua") then shell.run("wget run https://basalt.madefor.cc/install.lua release latest.lua SI/basalt.lua") end
if not fs.exists("SI/main.lua") then shell.run("wget https://raw.githubusercontent.com/banana-boye/SI-system/refs/heads/main/main.lua SI/main.lua") end
if not fs.exists("SI/extratools.lua") then shell.run("wget https://github.com/banana-boye/SI-system/blob/main/SI/extratools.lua SI/extratools.lua") end
if not fs.exists("SI/synth.lua") then shell.run("wget https://github.com/banana-boye/SI-system/blob/main/SI/synth.lua SI/synth.lua") end
if not fs.exists("SI/withdraw.lua") then shell.run("wget https://github.com/banana-boye/SI-system/blob/main/SI/withdraw.lua SI/withdraw.lua") end
if not fs.exists("SI/deposit.lua") then shell.run("wget https://github.com/banana-boye/SI-system/blob/main/SI/deposit.lua SI/deposit.lua") end
if not fs.exists("SI/organize.lua") then shell.run("wget https://github.com/banana-boye/SI-system/blob/main/SI/organize.lua SI/organize.lua") end

-- Run
shell.run("SI/main.lua")